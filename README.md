# ton-wallet-crystal-flutter
TON Wallet Flutter application. Manage Free TON wallets and access dApps directly from your cellphone

## How to build & run

1. Clone the project and run ```flutter pub get``` to load dependencies  

2. Clone the plugin from ```https://github.com/broxus/nekoton-flutter.git``` to folder alongside the project and do steps described in ```README.md``` to build it  

3. Run following commands  
```flutter pub run build_runner build --delete-conflicting-outputs```  
```flutter pub run easy_localization:generate -f keys -S assets/localizations```  

4. Create ```.env``` file in root of the project with ```HIVE_AES_CIPHER_KEY``` string contains 32 integers separated with spaces  
Example: ```HIVE_AES_CIPHER_KEY='4 8 15 16 23 42 ... 42 23 16 15 8 4'```  

5. Build commands
```flutter build appbundle --release --no-tree-shake-icons --no-shrink```
```flutter build apk --release --no-tree-shake-icons --no-shrink```
```flutter build apk --release --no-tree-shake-icons --no-shrink --split-per-abi```
```flutter build ios --release --no-tree-shake-icons --no-codesign```