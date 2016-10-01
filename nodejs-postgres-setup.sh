read -p "App domain [example.com, no www] " appurl
# Set up repositories
cd
curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
sudo bash ./nodesource_setup.sh
sudo apt-get update

# Upgrade entire system
sudo apt-get upgrade -y


# Install dependencies
sudo apt-get install -y nodejs build-essential nginx ufw postgresql postgresql-contrib

# Install PM2
sudo npm install -g pm2

# Enable firewall
ufw allow ssh
ufw allow http
ufw allow https
yes | ufw enable


########################### Variables #############################
workerprocesses=$(grep processor /proc/cpuinfo | wc -l)
workerconnections=$(ulimit -n)
global_nginx_conf="
user  www-data www-data;
worker_processes  $workerprocesses;
events {
    worker_connections  $workerconnections;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    server_tokens off;
    sendfile        on;
    #tcp_nopush     on;
    # Gzip configuration
    include /etc/nginx/conf/gzip.conf;
    # Add my servers
    include /etc/nginx/sites/*;
    # Buffers
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 2 1k;
    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;
    # Log off
    access_log off;
}
"
cache='
location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 365d;
}
'
gzipconf='
gzip on;
gzip_disable "msie6";
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_types text/plain text/css text/xml application/xml application/javascript application/x-javascript text/javascript;
'

#Auto security update rules
updaterules='echo "**************" >> /var/log/apt-security-updates
date >> /var/log/apt-security-updates
aptitude update >> /var/log/apt-security-updates
aptitude safe-upgrade -o Aptitude::Delete-Unused=false --assume-yes --target-release `lsb_release -cs`-security >> /var/log/apt-security-updates
echo "Security updates (if any) installed"'
rotaterules='/var/log/apt-security-updates {
    rotate 2
    weekly
    size 250k
    compress
    notifempty
}'
webdev="
# Redirect www to non www, can also be used to redirect to https
server  {
	listen 80;
	server_name         www.$appurl;
	rewrite     ^   http://\$server_name\$request_uri? permanent;
}
#server  {
#        listen 443 ssl;
#        server_name         $appurl;
#        ssl_certificate     /etc/nginx/ssl/$appurl.chained.crt;
#        ssl_certificate_key /etc/nginx/ssl/$appurl.key;
#        rewrite     ^   https://www.\$server_name\$request_uri? permanent;
#}
server {
    listen 80;
    server_name $appurl;

    location / {
        root /var/www/$appurl;
        index index.html index.htm;
        try_files $uri $uri/ $uri&$args =404;
    }

    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    client_max_body_size 32M;
    large_client_header_buffers 4 16k;
    include /etc/nginx/conf/cache.conf;
    include /etc/nginx/conf/gzip.conf;
    error_page 401 403 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
"
mkdir /etc/nginx/conf
mkdir /etc/nginx/sites
echo "$global_nginx_conf" > /etc/nginx/nginx.conf
echo "$cache" > /etc/nginx/conf/cache.conf
echo "$gzipconf" > /etc/nginx/conf/gzip.conf
echo "$webdev" > /etc/nginx/sites/web.dev

mkdir "/var/www/$appurl"
echo "Setup complete for $appurl" >> "/var/www/$appurl/index.html"

service nginx restart