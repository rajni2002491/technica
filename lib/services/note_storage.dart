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

      final userId = user.uid;

      final querySnapshot = await _firestore
          .collection('notes')
          .where('user_id', isEqualTo: userId)
          .orderBy('updated_at', descending: true)
          .get();

      final List<Note> notes = [];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          // Decrypt title and content
          // Support both encrypted and plain text (backward compatibility)
          String decryptedTitle;
          String decryptedContent;
          
          try {
            // Try to decrypt (if encrypted)
            if (data['encrypted_title'] != null && data['encrypted_title'].toString().isNotEmpty) {
              decryptedTitle = await _encryption.decryptLargeText(data['encrypted_title']);
            } else {
              // Fallback to plain text (for existing notes)
              decryptedTitle = data['title'] ?? '';
            }
            
            if (data['encrypted_content'] != null && data['encrypted_content'].toString().isNotEmpty) {
              decryptedContent = await _encryption.decryptLargeText(data['encrypted_content']);
            } else {
              // Fallback to plain text (for existing notes)
              decryptedContent = data['content'] ?? '';
            }
          } catch (e) {
            // If decryption fails, use plain text fallback
            print('Decryption error, using plain text: $e');
            decryptedTitle = data['title'] ?? data['encrypted_title'] ?? '';
            decryptedContent = data['content'] ?? data['encrypted_content'] ?? '';
          }
          
          notes.add(
            Note(
              id: doc.id,
              title: decryptedTitle,
              content: decryptedContent,
              createdAt:
                  (data['created_at'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              updatedAt:
                  (data['updated_at'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            ),
          );
        } catch (e) {
          print('Error parsing note: $e');
          continue;
        }
      }

      return notes;
    } catch (e) {
      print('Error getting notes: $e');
      return [];
    }
  }

  // Save a note with RSA encryption
  // isUpdate: true if updating existing note, false if creating new note
  // Returns immediately for instant UI response, saves in background
  void saveNote(Note note, {bool isUpdate = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }

      final userId = user.uid;

      // Encrypt title and content using RSA encryption
      String encryptedTitle;
      String encryptedContent;
      
      try {
        encryptedTitle = await _encryption.encryptLargeText(note.title);
        encryptedContent = await _encryption.encryptLargeText(note.content);
      } catch (e) {
        print('Encryption error: $e');
        // If encryption fails, don't save (security issue)
        return;
      }

      // Store encrypted note data
      final noteData = {
        'user_id': userId,
        'encrypted_title': encryptedTitle,
        'encrypted_content': encryptedContent,
        'created_at': Timestamp.fromDate(note.createdAt),
        'updated_at': Timestamp.fromDate(note.updatedAt),
        // Keep plain text fields empty for security (or remove them)
        'title': '', // Empty for security
        'content': '', // Empty for security
      };

      // Fire-and-forget save - returns immediately
      // Firestore persistence saves to local cache instantly
      // The stream listener will automatically update the UI
      if (isUpdate && note.id.isNotEmpty) {
        // Update existing note - use set with merge for better offline support
        _firestore
            .collection('notes')
            .doc(note.id)
            .set(noteData, SetOptions(merge: true));
      } else if (note.id.isNotEmpty) {
        // New note with specified ID
        _firestore
            .collection('notes')
            .doc(note.id)
            .set(noteData, SetOptions(merge: true));
      } else {
        // New note - let Firestore generate the ID
        _firestore.collection('notes').add(noteData);
      }
    } catch (e) {
      print('Error saving note: $e');
      // Errors are handled silently - stream will show the actual state
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
      print('Error deleting note: $e');
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

      final data = doc.data();
      if (data == null) {
        return null;
      }

      // Decrypt title and content
      // Support both encrypted and plain text (backward compatibility)
      String decryptedTitle;
      String decryptedContent;
      
      try {
        // Try to decrypt (if encrypted)
        if (data['encrypted_title'] != null && data['encrypted_title'].toString().isNotEmpty) {
          decryptedTitle = await _encryption.decryptLargeText(data['encrypted_title']);
        } else {
          // Fallback to plain text (for existing notes)
          decryptedTitle = data['title'] ?? '';
        }
        
        if (data['encrypted_content'] != null && data['encrypted_content'].toString().isNotEmpty) {
          decryptedContent = await _encryption.decryptLargeText(data['encrypted_content']);
        } else {
          // Fallback to plain text (for existing notes)
          decryptedContent = data['content'] ?? '';
        }
      } catch (e) {
        // If decryption fails, use plain text fallback
        print('Decryption error, using plain text: $e');
        decryptedTitle = data['title'] ?? data['encrypted_title'] ?? '';
        decryptedContent = data['content'] ?? data['encrypted_content'] ?? '';
      }

      return Note(
        id: doc.id,
        title: decryptedTitle,
        content: decryptedContent,
        createdAt:
            (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error getting note: $e');
      return null;
    }
  }
}
