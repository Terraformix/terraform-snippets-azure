#!/bin/bash

sudo apt-get update && sudo apt-get install nginx -y
sudo mkdir -p /var/www/html

echo "Welcome to the news path. Served from $(hostname)" | sudo tee /var/www/html/index.html > /dev/null

# Health endpoint to be able to periodically probe for health checks
echo "healthy" | sudo tee /var/www/html/healthz.html > /dev/null

sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    root /var/www/html;
    index index.html;

    location /news {
        try_files /index.html =404;
    }

    location /healthz {
        try_files /healthz.html =404;
    }
}

EOF

sudo systemctl restart nginx
echo "Nginx configured with news path: /news"
