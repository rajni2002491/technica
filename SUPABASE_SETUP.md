# Supabase Setup Guide

This app uses Supabase for cloud storage with RSA encryption. Follow these steps to set up your Supabase project:

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in your project details and wait for it to be created

## 2. Get Your Supabase Credentials

1. Go to your project settings
2. Navigate to "API" section
3. Copy your:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

## 3. Update main.dart

Replace the placeholders in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',  // Replace with your Project URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY',  // Replace with your Anon Key
);
```

## 4. Create the Database Table

1. Go to your Supabase project dashboard
2. Navigate to "SQL Editor"
3. Run the SQL script from `lib/supabase_setup.sql`

This will create:
- A `notes` table with encrypted fields
- Row Level Security (RLS) policies
- Indexes for optimal performance

## 5. Enable Anonymous Authentication (Optional)

If you want to use anonymous authentication:

1. Go to "Authentication" > "Providers" in your Supabase dashboard
2. Enable "Anonymous" provider (if available)
3. Alternatively, you can implement email/password authentication

## 6. Test the App

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. Create a note to test encryption and storage

## Security Notes

- **RSA Keys**: The app automatically generates RSA key pairs on first launch
- **Key Storage**: Keys are stored locally using SharedPreferences
- **Encryption**: All note titles and content are encrypted using RSA-OAEP before being sent to Supabase
- **Data Privacy**: Even if someone accesses your Supabase database, they cannot read your notes without the private key stored on your device

## Troubleshooting

### "Invalid API key" error
- Verify your Supabase URL and Anon Key are correct
- Make sure there are no extra spaces or quotes

### "Table does not exist" error
- Make sure you ran the SQL setup script in Supabase SQL Editor
- Check that the table name is `notes` (lowercase)

### "Permission denied" error
- Verify Row Level Security policies are set up correctly
- Check that you're authenticated (anonymous or otherwise)

### Encryption/Decryption errors
- Make sure the RSA keys are generated properly on first launch
- If keys are corrupted, clear app data and restart to regenerate keys

