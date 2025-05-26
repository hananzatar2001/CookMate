# Firebase Database Initialization Guide

## Database Initialization from JSON

When setting up the application for the first time and there's no collection in your Firebase database, you'll need to initialize it from your JSON file.

### Configuration Steps

1. Open your `database_config.dart` file
2. Set the following variables to `true`:

```dart
static const bool FALLBACK_TO_JSON = true;
static const bool INITIALIZE_FROM_JSON = true;
```

### Important Note

These settings should only be used during initial setup or development. Make sure to disable them in production mode by setting them to `false` once your database is properly initialized.
