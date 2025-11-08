# Quick Fix for Registration Issues

## Most Common Issue: Email/Password Not Enabled

**90% of registration failures are because Email/Password authentication is not enabled in Firebase Console.**

### Fix in 3 Steps:

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com/
   - Select your project: `technica-148c0`

2. **Enable Email/Password**
   - Click on **Authentication** in the left menu
   - Click on **Sign-in method** tab
   - Find **Email/Password** in the list
   - Click on it
   - **Enable** the first toggle (Email/Password)
   - Click **Save**

3. **Test Again**
   - Go back to your app
   - Try registering again
   - It should work now!

## Other Quick Checks

### ✅ Verify google-services.json
- File exists at: `android/app/google-services.json`
- Package name matches: `com.example.flutter_application_1`

### ✅ Verify Internet Connection
- Make sure you have internet access
- Try opening Firebase Console in browser

### ✅ Check Error Message
- Read the error message shown in the app
- It will tell you exactly what's wrong

### ✅ Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

## Still Not Working?

Check the console logs when you try to register. You should see:
- "Firebase initialized successfully"
- "Attempting to register user with email: ..."
- Any error messages

Share the error message and we can help further!

