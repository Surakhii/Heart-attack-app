# Heart Attack

Track your Red Bull and Monster consumption with your friends. Leaderboard included.

## Features

- Log Red Bull and Monster by flavor and size — caffeine auto-calculated
- Leaderboard: cans, caffeine, streak, daily average
- Filter by Today / This Week / This Month / All Time
- Personal stats with activity heatmap
- Google Sign-in, invite-code access control
- Profile photos, editable display names

## Stack

- Flutter (Android)
- Firebase Auth (Google Sign-in)
- Firestore
- Firebase Storage

## Install

Download the APK from [Releases](../../releases) and sideload it on Android.

> iPhone support coming if we ever feel like paying Apple $99/year.

## Access

Ask for the invite code.

## Firebase setup

This app uses Firebase. The config files are intentionally not committed.
After cloning: run `flutterfire configure` with your own Firebase project to
regenerate `lib/firebase_options.dart`, `android/app/google-services.json`
and `ios/Runner/GoogleService-Info.plist`, then build normally.
