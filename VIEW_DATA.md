# How to View Your Stored Data

## Option 1: View Firestore Data (Currently Using)

Your app is currently using **Firebase Firestore** to store notes.

### Steps to View Firestore Data:

1. **Go to Firebase Console**

   - Visit [Firebase Console](https://console.firebase.google.com/)
   - Sign in with your Google account

2. **Select Your Project**

   - Click on your project name from the list

3. **Navigate to Firestore Database**

   - Click on "Firestore Database" in the left sidebar
   - Or go to: Build → Firestore Database

4. **View Your Notes**

   - You'll see the `notes` collection
   - Click on it to see all stored notes
   - Each document represents a note with fields:
     - `user_id`: The Firebase user ID who owns the note
     - `title`: Note title
     - `content`: Note content
     - `created_at`: Creation timestamp
     - `updated_at`: Last update timestamp

5. **Filter by User**
   - You can filter documents by `user_id` to see notes for specific users
   - Click on any document to view its full data

### Data Structure:

```
Collection: notes
  Document ID: (auto-generated)
    - user_id: "firebase_user_id"
    - title: "My Note Title"
    - content: "Note content here..."
    - created_at: Timestamp
    - updated_at: Timestamp
```

---

## Option 2: View Supabase Data (If You Want to Switch)

If you want to switch to Supabase or view Supabase data:

### Steps to View Supabase Data:

1. **Go to Supabase Dashboard**

   - Visit [Supabase Dashboard](https://app.supabase.com/)
   - Sign in with your account

2. **Select Your Project**

   - Click on your project from the list

3. **Navigate to Table Editor**

   - Click on "Table Editor" in the left sidebar
   - Or go to: Database → Tables

4. **View Your Notes Table**

   - Click on the `notes` table
   - You'll see all stored notes with columns:
     - `id`: Note ID
     - `user_id`: User ID who owns the note
     - `encrypted_title`: Encrypted title (if using encryption)
     - `encrypted_content`: Encrypted content (if using encryption)
     - `title`: Plain text title (if not using encryption)
     - `content`: Plain text content (if not using encryption)
     - `created_at`: Creation timestamp
     - `updated_at`: Last update timestamp

5. **Use SQL Editor (Advanced)**
   - Go to "SQL Editor" in the left sidebar
   - Run queries like:
     ```sql
     SELECT * FROM notes;
     SELECT * FROM notes WHERE user_id = 'your_user_id';
     ```

---

## Quick Comparison

| Feature         | Firestore (Current)          | Supabase                          |
| --------------- | ---------------------------- | --------------------------------- |
| **View Data**   | Firebase Console → Firestore | Supabase Dashboard → Table Editor |
| **Data Format** | Documents in Collections     | Rows in Tables                    |
| **Query Tool**  | Firebase Console UI          | SQL Editor + Table Editor         |
| **Real-time**   | Built-in listeners           | Built-in subscriptions            |

---

## View Data in Your App (Debug)

You can also add debug logging to see data in your app:

### Add Debug Print in NoteStorage:

```dart
// In note_storage.dart, add this to see data:
Future<List<Note>> getNotes() async {
  // ... existing code ...
  print('Total notes found: ${notes.length}');
  for (var note in notes) {
    print('Note: ${note.title} - ${note.content.substring(0, 20)}...');
  }
  return notes;
}
```

### Use Flutter DevTools:

1. Run your app in debug mode
2. Open Flutter DevTools
3. Go to "Logging" tab to see print statements
4. Or use the console output

---

## Need Help?

- **Firestore**: Check [Firebase Documentation](https://firebase.google.com/docs/firestore)
- **Supabase**: Check [Supabase Documentation](https://supabase.com/docs)
