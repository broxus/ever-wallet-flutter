# ever-wallet-flutter

EVER Wallet Flutter application. Manage Everscale wallets and access dApps directly from your cellphone

## Getting Started 🚀

1. Clone plugin from `https://github.com/broxus/nekoton-flutter.git` to folder alongside the project and do steps described in `README.md` to build it

2. Rename nekoton-flutter directory to nekoton_flutter

3. Generate code:
```sh
$ flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. Generate l10n:
```sh
$ flutter gen-l10n
```

## Fastlane automation 🤖

1. Put creds/keys files:

   * android/crystal.keystore // *Android signing*
   * android/key.properties // *Android signing*
   * android/fastlane/GooglePlayServiceAccount.json // *Android deploy*
   * ios/fastlane/AuthKey_L4N29B6Z42.p8 // *iOS deploy*
   * fastlane/FirebaseAPIKey.json // *Firebase Realtime database, build number*

2. Install fastlane:

```sh
brew install fastlane
```

3. Install certificates for iOS deployment:

```sh
fastlane ios match_assure
```

4. Install node modules (yeah, baby, node modules in the flutter project):

```sh
npm install
```

5. Deploy apps to Testflight and Google Play Internale testing channel:

```sh
fastlane deploy_store
```

## Working with Translations 🌐

This project relies on [flutter_localizations][flutter_localizations_link] and follows the [official internationalization guide for Flutter][internationalization_link].

### Adding Strings

1. To add a new localizable string, open the `app_en.arb` file at `lib/l10n/arb/app_en.arb`.

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

2. Then add a new key/value and description

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    },
    "helloWorld": "Hello World",
    "@helloWorld": {
        "description": "Hello World Text"
    }
}
```

3. Use the new string

```dart
import 'package:flutter_rimo/l10n/l10n.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  return Text(l10n.helloWorld);
}
```

### Adding Supported Locales

Update the `CFBundleLocalizations` array in the `Info.plist` at `ios/Runner/Info.plist` to include the new locale.

```xml
    ...

    <key>CFBundleLocalizations</key>
	<array>
		<string>en</string>
		<string>es</string>
	</array>

    ...
```

### Adding Translations

1. For each supported locale, add a new ARB file in `lib/l10n/arb`.

```
├── l10n
│   ├── arb
│   │   ├── app_en.arb
│   │   └── app_es.arb
```

2. Add the translated strings to each `.arb` file:

`app_en.arb`

```arb
{
    "@@locale": "en",
    "counterAppBarTitle": "Counter",
    "@counterAppBarTitle": {
        "description": "Text shown in the AppBar of the Counter Page"
    }
}
```

`app_es.arb`

```arb
{
    "@@locale": "es",
    "counterAppBarTitle": "Contador",
    "@counterAppBarTitle": {
        "description": "Texto mostrado en la AppBar de la página del contador"
    }
}
```