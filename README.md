# example

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# install 
   # first
    git clone https://github.com/Baseflow/flutter_wizard.git flutter_wizard_example
    cp -r flutter_wizard_example/example/ .
    cd example/

   # from github now
    git clone git@github.com:yguskov/anton.git 

# Init
flutter pub get
   # may be  
    flutter pub add flutter_wizard
flutter create . --platforms web

# run 
export CHROME_EXECUTABLE="/usr/bin/chromium-browser"
flutter doctor -v
flutter run -d chrome --web-renderer html --verbose
flutter build web --release --base-href /anketa/
rsync -avz --delete build/web/ root@5.187.2.205:/var/www/html/anketa

# go api
Установите MySQL и создайте базу данных flutter_app
Обновите config.json с вашими данными БД
Обновить зависимости: go mod tidy
Запустите: go run main.go

# database and user
CREATE DATABASE IF NOT EXISTS anton;
CREATE USER IF NOT EXISTS 'anton'@'localhost' IDENTIFIED BY 'ant';
GRANT ALL PRIVILEGES ON anton.* TO 'anton'@'localhost';
FLUSH PRIVILEGES;

# Регистрация пользователя
curl -X POST http://localhost:8080/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "user_data": {
      "name": "John Doe",
      "age": 30,
      "interests": ["programming", "reading"]
    }
  }'

# Логин
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

