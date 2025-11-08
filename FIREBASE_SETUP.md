# Firebase Setup Guide

This app uses Firebase Authentication and Firestore for secure note storage with RSA encryption. Follow these steps to set up your Firebase project.

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard to create your project

## 2. Enable Authentication

1. In Firebase Console, go to **Authentication** > **Get started**
2. Enable **Email/Password** authentication:
   - Click on "Sign-in method" tab
   - Click on "Email/Password"
   - Enable it and click "Save"

## 3. Create Firestore Database

1. In Firebase Console, go to **Firestore Database** > **Create database**
2. Choose **Start in test mode** (for development) or **Start in production mode**
3. Select a location for your database (choose the closest to your users)
4. Click "Enable"

## 4. Set Up Firestore Security Rules

Go to **Firestore Database** > **Rules** and update the rules to:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Notes collection - users can only access their own notes
    match /notes/{noteId} {
      // Allow read/write if user is authenticated and owns the note
      allow read, write: if request.auth != null && 
        resource.data.user_id == request.auth.uid;
      
      // Allow create if user is authenticated and sets their own user_id
      allow create: if request.auth != null && 
        request.resource.data.user_id == request.auth.uid;
    }
  }
}
```

**Important**: For production, you should tighten these rules further and implement proper validation.

## 5. Add Android App to Firebase

1. In Firebase Console, click the Android icon (or "Add app")
2. Enter your Android package name: `com.example.flutter_application_1`
3. Register the app
4. Download `google-services.json`
5. Place it in `android/app/` directory (replace the existing one if present)

## 6. Add iOS App to Firebase (Optional)

1. In Firebase Console, click the iOS icon
2. Enter your iOS bundle ID
3. Register the app
4. Download `GoogleService-Info.plist`
5. Open Xcode and add it to the `ios/Runner` directory

## 7. Verify Setup

### Android Setup Verification

1. ✅ `android/app/google-services.json` exists
2. ✅ `android/build.gradle.kts` has Google Services plugin:
   ```kotlin
   id("com.google.gms.google-services") version "4.4.4" apply false
   ```
3. ✅ `android/app/build.gradle.kts` applies the plugin:
   ```kotlin
   id("com.google.gms.google-services")
   ```
4. ✅ `android/app/build.gradle.kts` has Firebase BOM:
   ```kotlin
   implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
   ```

### Flutter Dependencies Verification

Your `pubspec.yaml` should have:
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
```

## 8. Test the App

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. Try creating an account and logging in
4. Create a note to verify Firestore integration

## 9. Firebase Console Features

### Monitor Authentication
- Go to **Authentication** > **Users** to see registered users

### Monitor Firestore
- Go to **Firestore Database** to see stored notes (encrypted)

### Monitor Usage
- Go to **Usage and billing** to monitor your Firebase usage

## Security Features

- **RSA Encryption**: All notes are encrypted with RSA-OAEP before being stored in Firestore
- **User Isolation**: Each user can only access their own notes (enforced by Firestore security rules)
- **Authentication**: Firebase Authentication handles user registration and login securely
- **Private Keys**: RSA private keys are stored locally on the device and never sent to Firebase

## Troubleshooting

### "FirebaseApp not initialized" error
- Make sure `Firebase.initializeApp()` is called in `main()` before `runApp()`
- Verify `google-services.json` is in the correct location

### "MissingPluginException" error
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the app

### Authentication errors
- Verify Email/Password authentication is enabled in Firebase Console
- Check that your app's package name matches Firebase configuration

### Firestore permission errors
- Check Firestore security rules
- Verify the user is authenticated before accessing Firestore
- Check that `user_id` field matches the authenticated user's UID

### Build errors on Android
- Make sure `google-services.json` is in `android/app/` directory
- Verify Google Services plugin is applied in `build.gradle.kts`
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

## Production Considerations

1. **Security Rules**: Update Firestore rules for production with stricter validation
2. **Indexes**: Create composite indexes for queries if needed
3. **Backup**: Set up Firestore backups
4. **Monitoring**: Enable Firebase Performance Monitoring and Crashlytics
5. **Analytics**: Consider enabling Firebase Analytics
6. **Rate Limiting**: Implement rate limiting for authentication attempts

## Support

For more information, visit:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

