#!/bin/bash

SERVER="root@5.187.2.205"
APP_DIR="/var/www/go/anketa"
WEB_DIR="/var/www/html/anketa"
BINARY_NAME="api-server"

echo "🔨 Building API server..."
cd ~/pro/anton/example/go-api
GOOS=linux GOARCH=amd64 go build -o $BINARY_NAME main.go

echo "🚀 Stopping service on server..."
ssh $SERVER "cd $APP_DIR && chmod +x $BINARY_NAME && sudo systemctl stop anketa"

echo "📤 Copying to server..."
scp $BINARY_NAME $SERVER:$APP_DIR/
# scp .env $SERVER:$APP_DIR/ 2>/dev/null || echo "No .env file to copy"

echo "🚀 Starting service on server..."
ssh $SERVER "cd $APP_DIR && chmod +x $BINARY_NAME && sudo systemctl restart anketa"

echo "✅ Go deployment completed!"
echo "🔨 Building WEB ..."

cd ~/pro/anton/example
flutter build web --release --base-href /anketa/ --dart-define=API_URL=http://5.187.2.205:8993/api
rsync -avz --delete build/web/ $SERVER:$WEB_DIR

echo "✅ Deployment completed!"
