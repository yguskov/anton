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
echo -e "\033[2A📤 Copying to server ✅        "

echo "🚀 Starting service on server..."
ssh $SERVER "cd $APP_DIR && chmod +x $BINARY_NAME && sudo systemctl restart hr"

echo "✅ Go deployment completed!"
echo ""
echo "🔨 Building WEB ..."

cd $BUILD_DIR
# flutter build web --web-renderer html --profile --base-href /app/ --dart-define=API_URL=http://5.42.120.212:8993/api --dart-define=HTML_URL=/
flutter build web --release --base-href /app/ --dart-define="HTML_URL=/" --dart-define="API_URL=https://statuswindow.ru:8993/api"

echo "✅ completed!"
echo ""

# Google Analitycs
# sed -i '/<!-- INJECT_GA_HERE -->/r build/web/ga.html' build/web/index.html
# sed -i '/<!-- INJECT_GA_HERE -->/d' build/web/index.html

echo "📤 Copying to server..."

rsync -avz --delete --quiet web/html/ $SERVER:$WEB_DIR
rsync -az --delete --quiet --exclude=html build/web/ $SERVER:$WEB_DIR/app

echo -e "\033[1A📤 Copying to server ✅        "

echo "✅ Insert Google Analitycs"
ssh $SERVER "sed -i '/<!-- INJECT_GA_HERE -->/r $WEB_DIR/app/ga.html' $WEB_DIR/index.html $WEB_DIR/landing2.html $WEB_DIR/app/index.html && sed -i '/<!-- INJECT_GA_HERE -->/d' $WEB_DIR/index.html $WEB_DIR/landing2.html $WEB_DIR/app/index.html && rm -f $WEB_DIR/app/ga.html"

# sudo find /var/www/html/hr -type d -exec chmod 750 {} \;
ssh $SERVER "cd $WEB_DIR && sed -i 's/APP_DIR/app/' index.html && sudo chown -R deploy:www-data $WEB_DIR && sudo find /var/www/html/hr -type d -exec chmod 750 {} \;"

echo "✅ Deployment completed!"
