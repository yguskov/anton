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

export CHROME_EXECUTABLE="/usr/bin/chromium-browser"
flutter doctor -v
flutter run -d chrome --web-renderer html --verbose
flutter build web --release --base-href /anketa/
rsync -avz --delete build/web/ root@5.187.2.205:/var/www/html/anketa

