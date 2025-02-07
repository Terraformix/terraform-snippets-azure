#!/bin/bash

VUE_REPO_URL="https://github.com/Terraformix/greetify"
PROJECT_NAME="greetify"
FRONTEND_PATH="greetify/greetify-frontend"
NGINX_SITE_CONF="/etc/nginx/sites-available/default"
BUILD_DIR="/var/www/html"

VITE_IS_STATIC="true"

export DEBIAN_FRONTEND=noninteractive

sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx git curl

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo DEBIAN_FRONTEND=noninteractive apt install -y nodejs

# Clone the repository
git clone "$VUE_REPO_URL" "$PROJECT_NAME"

cd "$FRONTEND_PATH" || exit


# Export environment variable for Vite to prevent making server side calls
export VITE_IS_STATIC=$VITE_IS_STATIC

npm install
npm run build

sudo mkdir -p "$BUILD_DIR"
sudo cp -r dist/* "$BUILD_DIR/"

# Configure Nginx
sudo bash -c "cat > $NGINX_SITE_CONF << 'EOF'
server {
    listen 80;
    server_name _;
    root $BUILD_DIR;

    index index.html;
    
    location / {
        try_files \$uri /index.html;
    }

    error_page 404 /index.html;

    location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2?|eot|ttf|svg|otf)\$ {
        expires 6M;
        access_log off;
        add_header Cache-Control \"public\";
    }
}
EOF"

sudo ln -sf "$NGINX_SITE_CONF" /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
