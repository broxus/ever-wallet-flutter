# ton-wallet-crystal-flutter

EVER Wallet Flutter application. Manage Everscale wallets and access dApps directly from your cellphone

## How to build & run

1. Clone the project and run `flutter pub get` to load dependencies

2. Clone the plugin from `https://github.com/broxus/nekoton-flutter.git` to folder alongside the project and do steps described in `README.md` to build it

3. Run following commands  
   `flutter pub run build_runner build --delete-conflicting-outputs`  
   `flutter gen-l10n`

4. Create `.env` file in root of the project with `HIVE_AES_CIPHER_KEY` string contains 32 integers separated with spaces  
   Example: `HIVE_AES_CIPHER_KEY='4 8 15 16 23 42 ... 42 23 16 15 8 4'`

5. Build commands  
   `flutter build ios --release --bundle-sksl-path flutter_01.sksl.json`  
   `flutter build apk --release --bundle-sksl-path flutter_02.sksl.json`  
   `flutter build appbundle --release --bundle-sksl-path flutter_02.sksl.json`
