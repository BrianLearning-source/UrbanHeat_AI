# UrbanHeat AI frontend

## Supabase setup

From `Frontend`, create a local `.env` file from the example:

```powershell
Copy-Item .env.example .env
```

Set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` to the URL and publishable
key from your Supabase project. Do not put a `service_role` key in the Flutter
application. The `.env` file is ignored by Git and bundled as an app asset, so
it must exist before building or running the application.

Enable the Email provider in Supabase Authentication to use email registration
and login. To let a new email/password account enter Home immediately, disable
email confirmation in the Supabase Dashboard under **Authentication → Providers
→ Email** (turn off **Confirm email**, then save). The app only routes to Home
when Supabase returns a session; if confirmation is still required and no
session is returned, the user is sent to login instead.

Registration stores `full_name` in Supabase Auth user metadata. This does not
create or update a row in a separate profile table. The profile screen continues
to use the existing `ProfileRepository`; persisting account profiles requires a
separately designed table, row-level security policies, and repository
implementation before connecting it to that screen.

## Run and validate

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
