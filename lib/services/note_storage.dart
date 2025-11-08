import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';
import 'rsa_encryption.dart';

class NoteStorage {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final RSAEncryption _encryption = RSAEncryption();

  NoteStorage(this._firestore, this._auth);

  // Get all notes for the current user
  Future<List<Note>> getNotes() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('notes')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('updated_at', descending: true)
          .get();

      final List<Note> notes = [];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          // Decrypt title and content
          final decryptedTitle = data['encrypted_title'] != null
              ? await _encryption.decryptLargeText(data['encrypted_title'])
              : data['title'] ?? '';
          final decryptedContent = data['encrypted_content'] != null
              ? await _encryption.decryptLargeText(data['encrypted_content'])
              : data['content'] ?? '';

          notes.add(
            Note(
              id: doc.id,
              title: decryptedTitle,
              content: decryptedContent,
              createdAt: (data['created_at'] as Timestamp).toDate(),
              updatedAt: (data['updated_at'] as Timestamp).toDate(),
            ),
          );
        } catch (e) {
          // Skip notes that can't be decrypted
          continue;
        }
      }

      return notes;
    } catch (e) {
      return [];
    }
  }

  // Save a note
  Future<bool> saveNote(Note note) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Encrypt title and content
      final encryptedTitle = await _encryption.encryptLargeText(note.title);
      final encryptedContent = await _encryption.encryptLargeText(note.content);

      final noteData = {
        'user_id': user.uid,
        'encrypted_title': encryptedTitle,
        'encrypted_content': encryptedContent,
        'created_at': Timestamp.fromDate(note.createdAt),
        'updated_at': Timestamp.fromDate(note.updatedAt),
      };

      // Check if note exists
      final docRef = _firestore.collection('notes').doc(note.id);
      final doc = await docRef.get();

      if (doc.exists) {
        // Update existing note
        await docRef.update(noteData);
      } else {
        // Insert new note
        await docRef.set(noteData);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete a note
  Future<bool> deleteNote(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      await _firestore.collection('notes').doc(id).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get a single note by ID
  Future<Note?> getNoteById(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore.collection('notes').doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      // Verify note belongs to user
      if (data['user_id'] != user.uid) {
        return null;
      }

      // Decrypt title and content
      final decryptedTitle = data['encrypted_title'] != null
          ? await _encryption.decryptLargeText(data['encrypted_title'])
          : data['title'] ?? '';
      final decryptedContent = data['encrypted_content'] != null
          ? await _encryption.decryptLargeText(data['encrypted_content'])
          : data['content'] ?? '';

      return Note(
        id: doc.id,
        title: decryptedTitle,
        content: decryptedContent,
        createdAt: (data['created_at'] as Timestamp).toDate(),
        updatedAt: (data['updated_at'] as Timestamp).toDate(),
      );
    } catch (e) {
      return null;
    }
  }
}
