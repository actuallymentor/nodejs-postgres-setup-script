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