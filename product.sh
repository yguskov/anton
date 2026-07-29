#!/bin/bash

SERVER="deploy@5.42.120.212"
APP_DIR="/var/www/go/hr"
WEB_DIR="/var/www/html/hr"
BINARY_NAME="api-server"
BUILD_DIR=$(pwd)

echo "🔨 Building API server..."
cd $BUILD_DIR/go-api
GOOS=linux GOARCH=amd64 go build -o $BINARY_NAME main.go


eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_anton
echo "🚀 Stopping service on server..."
ssh $SERVER "cd $APP_DIR && chmod +x $BINARY_NAME && sudo systemctl stop hr"

echo "📤 Copying to server..."
scp $BINARY_NAME $SERVER:$APP_DIR/
# scp .env $SERVER:$APP_DIR/ 2>/dev/null || echo "No .env file to copy"

echo "🚀 Starting service on server..."
ssh $SERVER "cd $APP_DIR && chmod +x $BINARY_NAME && sudo systemctl restart hr"

echo "✅ Go deployment completed!"
echo "🔨 Building WEB ..."

cd $BUILD_DIR
# flutter build web --release --base-href /app/ --dart-define=API_URL=http://5.42.120.212:8993/api --dart-define=HTML_URL=/
flutter build web --profile --base-href /app/ --dart-define="HTML_URL=/" --dart-define="API_URL=http://statuswindow.ru:8993/api"
rsync -avz --delete web/html/ $SERVER:$WEB_DIR
rsync -az --delete --progress --exclude=html build/web/ $SERVER:$WEB_DIR/app
# sudo find /var/www/html/hr -type d -exec chmod 750 {} \;
ssh $SERVER "cd $WEB_DIR && sed -i 's/APP_DIR/app/' index.html && sudo chown -R deploy:www-data $WEB_DIR && sudo find /var/www/html/hr -type d -exec chmod 750 {} \;"

echo "✅ Deployment completed!"
