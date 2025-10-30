cd ~/pro/anton/example
flutter build web --release --base-href /anketa/
rsync -avz --delete build/web/ root@5.187.2.205:/var/www/html/anketa