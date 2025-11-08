# Troubleshooting Registration Issues

## Common Registration Failures and Solutions

### 1. "Operation not allowed" Error

**Cause**: Email/Password authentication is not enabled in Firebase Console.

**Solution**:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** > **Sign-in method**
4. Click on **Email/Password**
5. Enable "Email/Password" (first toggle)
6. Click **Save**

### 2. "Network request failed" Error

**Cause**: No internet connection or Firebase not accessible.

**Solution**:
- Check your internet connection
- Verify you can access Firebase Console
- Check if Firebase is blocked by firewall
- Try again after a few seconds

### 3. "Invalid email" Error

**Cause**: Email format is incorrect.

**Solution**:
- Ensure email contains @ symbol
- Ensure email has a domain (e.g., .com, .org)
- Remove any spaces before/after email
- Use a valid email format: `user@example.com`

### 4. "Weak password" Error

**Cause**: Password doesn't meet Firebase requirements.

**Solution**:
- Password must be at least 6 characters
- Use a combination of letters, numbers, and special characters
- Avoid common passwords

### 5. "Email already in use" Error

**Cause**: An account with this email already exists.

**Solution**:
- Try signing in instead of registering
- Use a different email address
- Reset password if you forgot it

### 6. Firebase Not Initialized Error

**Cause**: Firebase initialization failed.

**Solution**:
1. Check `google-services.json` is in `android/app/` directory
2. Verify `google-services.json` is valid and matches your project
3. Check Firebase project ID matches in console
4. Run `flutter clean` and `flutter pub get`
5. Rebuild the app

### 7. Build/Compilation Errors

**Cause**: Missing dependencies or configuration issues.

**Solution**:
```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

### 8. "MissingPluginException" Error

**Cause**: Native plugins not properly linked.

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

## Debugging Steps

### Step 1: Check Firebase Console

1. Verify Email/Password is enabled:
   - Go to Firebase Console > Authentication > Sign-in method
   - Ensure Email/Password is enabled

2. Check Firebase project:
   - Verify project ID matches `google-services.json`
   - Check project is active and not deleted

3. Check Firestore (if needed):
   - Go to Firestore Database
   - Verify database is created

### Step 2: Check App Configuration

1. Verify `google-services.json`:
   - File exists in `android/app/` directory
   - Package name matches: `com.example.flutter_application_1`
   - File is valid JSON

2. Check `build.gradle.kts`:
   - Google Services plugin is applied
   - Firebase BOM is included

3. Check `AndroidManifest.xml`:
   - Internet permission is present

### Step 3: Check Logs

Run the app and check console output for:
- "Firebase initialized successfully"
- "Attempting to register user with email: ..."
- Any error messages

### Step 4: Test Connection

1. Try logging in with an existing account
2. Check if Firebase Console shows the authentication attempt
3. Verify network connectivity

## Quick Fixes

### Fix 1: Enable Email/Password Authentication
```bash
# This must be done in Firebase Console, not in code
# Go to: Firebase Console > Authentication > Sign-in method > Email/Password > Enable
```

### Fix 2: Re-download google-services.json
1. Go to Firebase Console
2. Project Settings > General
3. Download `google-services.json` for Android
4. Replace the file in `android/app/` directory

### Fix 3: Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Fix 4: Check Firebase Project Status
- Ensure project is not on Blaze plan restrictions (if using free tier)
- Check if project has any quotas exceeded
- Verify billing is set up if required

## Testing Registration

### Test Case 1: Valid Registration
- Email: `test@example.com`
- Password: `password123`
- Expected: Registration succeeds

### Test Case 2: Invalid Email
- Email: `invalid-email`
- Password: `password123`
- Expected: "Invalid email address" error

### Test Case 3: Weak Password
- Email: `test@example.com`
- Password: `12345`
- Expected: "Password must be at least 6 characters" error

### Test Case 4: Existing Email
- Email: `existing@example.com` (already registered)
- Password: `password123`
- Expected: "Email already in use" error

## Getting Help

If issues persist:

1. **Check Firebase Console Logs**:
   - Go to Firebase Console > Authentication > Users
   - Check if registration attempts are logged

2. **Check App Logs**:
   - Run app with `flutter run -v` for verbose output
   - Look for Firebase-related errors

3. **Verify Firebase Setup**:
   - Follow `FIREBASE_SETUP.md` step by step
   - Use `SETUP_CHECKLIST.md` to verify configuration

4. **Common Issues**:
   - Firebase project not created
   - Wrong `google-services.json` file
   - Email/Password not enabled
   - Network connectivity issues
   - Firebase quota exceeded

## Error Code Reference

| Error Code | Meaning | Solution |
|------------|---------|----------|
| `weak-password` | Password too weak | Use stronger password (6+ chars) |
| `email-already-in-use` | Email exists | Sign in instead or use different email |
| `invalid-email` | Invalid email format | Check email format |
| `operation-not-allowed` | Auth method disabled | Enable Email/Password in Firebase Console |
| `network-request-failed` | Network error | Check internet connection |
| `too-many-requests` | Rate limited | Wait and try again |

