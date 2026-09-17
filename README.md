# Sized Up

Sized Up is a personal CRM for organizing the parts of everyday life that are usually scattered across different apps.

The project aims to bring together three core areas:

- Calendar for events, planning, and time-sensitive information.
- Notes for ideas, lists, references, and personal records.
- People for contacts, relationships, and interaction history.

The app is designed to grow beyond these initial sections. Future features may include user-defined fields, search and filtering, account management, data export, and synchronization across devices.

## Tech stack

- Flutter and Dart
- Material 3
- Isar for local persistence

## Getting started

Install Flutter, then run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

When an Isar model changes, regenerate the `.g.dart` files with the build runner command before analyzing or building the app.

## Project structure

```text
lib/
├── app/          Application configuration and theme
├── core/         Shared infrastructure such as the database service
├── features/     Feature-specific models, repositories, and screens
└── navigation/   App shell, sections, navigation, and quick actions
```

The project follows a feature-oriented structure so that each main area can evolve independently as the application grows.
