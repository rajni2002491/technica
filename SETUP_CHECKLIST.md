# Firebase Setup Checklist

Use this checklist to verify your Firebase setup is complete.

## ✅ Firebase Project Setup
- [ ] Firebase project created
- [ ] Project ID: `technica-148c0` (or your project ID)
- [ ] Billing enabled (if needed for production)

## ✅ Authentication Setup
- [ ] Email/Password authentication enabled in Firebase Console
- [ ] Authentication > Sign-in method > Email/Password > Enabled

## ✅ Firestore Database Setup
- [ ] Firestore Database created
- [ ] Security rules configured (see `firestore.rules`)
- [ ] Rules deployed to Firebase

## ✅ Android Configuration
- [ ] `google-services.json` downloaded from Firebase Console
- [ ] `google-services.json` placed in `android/app/` directory
- [ ] Package name matches: `com.example.flutter_application_1`
- [ ] Google Services plugin added to `android/build.gradle.kts`
- [ ] Google Services plugin applied in `android/app/build.gradle.kts`
- [ ] Firebase BOM added to `android/app/build.gradle.kts`
- [ ] Internet permission added to `AndroidManifest.xml`

## ✅ Flutter Dependencies
- [ ] `firebase_core: ^3.6.0` in `pubspec.yaml`
- [ ] `firebase_auth: ^5.3.1` in `pubspec.yaml`
- [ ] `cloud_firestore: ^5.4.4` in `pubspec.yaml`
- [ ] Dependencies installed (`flutter pub get`)

## ✅ Code Configuration
- [ ] `Firebase.initializeApp()` called in `main.dart`
- [ ] `AuthWrapper` implemented for authentication state
- [ ] `NoteStorage` updated to use Firestore
- [ ] All screens updated to use Firebase instead of Supabase
- [ ] Login screen implemented
- [ ] Register screen implemented
- [ ] Logout functionality added

## ✅ Security
- [ ] RSA encryption working (keys generated on first launch)
- [ ] Firestore security rules enforce user isolation
- [ ] Private keys stored locally only

## ✅ Testing
- [ ] App builds successfully
- [ ] Can register new user
- [ ] Can login with existing user
- [ ] Can create notes
- [ ] Can edit notes
- [ ] Can delete notes
- [ ] Can logout
- [ ] Notes are encrypted before storing
- [ ] Notes decrypt correctly when loading

## 🔧 Quick Test Commands

```bash
# Install dependencies
flutter pub get

# Analyze code
flutter analyze

# Run the app
flutter run

# Build for release (Android)
flutter build apk --release
```

## 📝 Notes
- RSA keys are automatically generated on first app launch
- Keys are stored locally using SharedPreferences
- All notes are encrypted with RSA-OAEP before being sent to Firestore
- Each user can only access their own notes (enforced by Firestore rules)

## 🚨 Common Issues

### Firebase not initialized
- Check that `Firebase.initializeApp()` is called before `runApp()`
- Verify `google-services.json` is in the correct location

### Authentication errors
- Verify Email/Password is enabled in Firebase Console
- Check package name matches Firebase configuration

### Firestore permission errors
- Check security rules are deployed
- Verify user is authenticated before accessing Firestore
- Check `user_id` field matches authenticated user's UID

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the app

