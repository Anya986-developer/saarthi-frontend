
#!/bin/bash
set -e

echo "Installing Flutter SDK..."

git clone --depth 1 --branch 3.44.0 \
  https://github.com/flutter/flutter.git "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

echo "Configuring Flutter web..."
flutter config --enable-web

echo "Installing dependencies..."
flutter pub get

echo "Building Saarthi for web..."
flutter build web --release

echo "Saarthi build completed successfully!"
