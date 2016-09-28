# NodeJS With PostgreSQL & PM2

Setup script for NodeJS apps using PM2 and PostgreSQL as a database.

## After installation

* Enable PM2 for your app (See [Digital Ocean Community](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-node-js-application-for-production-on-ubuntu-16-04))
```shell
pm2 start hello.js
pm2 startup systemd
systemctl status pm2
# Other commands
pm2 stop appname
pm2 restart appname
pm2 list
```

* Enable SSL for your app (See [Digital Ocean Community](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-node-js-application-for-production-on-ubuntu-16-04))
```shell
sudo apt-get install letsencrypt
sudo systemctl stop nginx
sudo letsencrypt certonly --standalone
# Certs now available in /etc/letsencrypt/your_domain_name/
```

* Setup a database for your app (See [Digital Ocean Community](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04))
``` shell
# Log in as postgres user
sudo -i -u postgres
# Access db
psql
# Make new user
createuser --interactive # or when not logged in as postgres:
sudo -u postgres createuser --interactive 
#create db from within postgres user
createdb yourapp
# When handling sensitive stuff on the command line
rm ~/.psql_history

#One way of making a user with a database
sudo adduser app
sudo su - postgres
psql
CREATE USER app WITH PASSWORD 'password';
CREATE DATABASE app OWNER app;
```
