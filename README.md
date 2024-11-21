<div align="center">
    <img src="https://github.com/user-attachments/assets/85c6e769-3b3f-453f-a4dc-18429ad5f2b0">
  <p></p>
</div>

<div align="center">


![Flutter Badge](https://img.shields.io/badge/Flutter-blue?logo=flutter&amp;logoColor=white&style=flat)
![GitHub stars](https://img.shields.io/github/stars/paugarcia32/ToDo-List-App)
![GitHub issues](https://img.shields.io/github/issues/paugarcia32/ToDo-List-App)
![GitHub forks](https://img.shields.io/github/forks/paugarcia32/ToDo-List-App)
![GitHub PRs](https://img.shields.io/github/issues-pr/paugarcia32/ToDo-List-App)
![SQLite Badge](https://img.shields.io/badge/SQLite-%2307405e.svg?logo=sqlite&logoColor=white&style=flat)

</div>




# ToDo List App

An example todos app that showcases bloc state management patterns.

---

## 📦 Stack

- [**Flutter**](https://flutter.dev/) - Open Source SDK
- [**Shared Preferences**](https://pub.dev/packages/shared_preferences) - persistent storage for simple data
- [**BLoC**](https://bloclibrary.dev/) - Predictable state management library for Dart.


## ⤵️ Instalation

1. Download project
   
```bash
git clone https://github.com/paugarcia32/ToDo-List-App.git
```

2. Install dependencies

```bash
dart pub global activate very_good_cli
```

```bash
very_good packages get --recursive
```
   
```bash
flutter pub get
```




## 🚀 How to run and build

This project contains 3 flavors:

- development
- staging
- production

To run the desired flavor either use the launch configuration in VSCode/Android Studio or use the following commands:

```sh
# Development
$ flutter run --flavor development --target lib/main_development.dart

# Staging
$ flutter run --flavor staging --target lib/main_staging.dart

# Production
$ flutter run --flavor production --target lib/main_production.dart
```

_\*Flutter Todos works on iOS, Android, Web, and Windows._

---

## Running Tests 🧪

To run all unit and widget tests use the following command:

```sh
$ flutter test --coverage --test-randomize-ordering-seed random
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

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
import 'package:flutter_todos/l10n/l10n.dart';

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

### Generating Translations

To use the latest translations changes, you will need to generate them:

1. Generate localizations for the current project:

```sh
flutter gen-l10n --arb-dir="lib/l10n/arb"
```

Alternatively, run `flutter run` and code generation will take place automatically.




## 🔗 Links
[![blog](https://img.shields.io/badge/my_website-000?style=for-the-badge&logo=ko-fi&logoColor=white)](https://www.paugarcia.dev/)
[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/paugarcia32/)



