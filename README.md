# the-line-app

A simple tram/bus timetable app written in Flutter (De Lijn - Belgium)

## Development

This app was developed for educational purpose only. I will use fluter as base framework for the app and explore how to make API request to HTTP and handle App permissions.

## API

The API I am using comes from the national public transportation service in Belgium De Lijn. I have discovered the API thanks to Chome Dev tools and Postman.

## How to run

```bash
flutter channel stable
flutter upgrade
cd the_line_app
flutter create .
```

Don't forget to add the following permission to your **AndroidManifest.xml**.

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Finally run the app.

```bash
flutter run
```
