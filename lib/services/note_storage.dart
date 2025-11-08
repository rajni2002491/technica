import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NoteStorage {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

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
          notes.add(
            Note(
              id: doc.id,
              title: data['title'] ?? '',
              content: data['content'] ?? '',
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

  // Save a note (store normally without encryption)
  // isUpdate: true if updating existing note, false if creating new note
  // Returns immediately for instant UI response, saves in background
  void saveNote(Note note, {bool isUpdate = false}) {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }

      final userId = user.uid;

      // Store note data normally (no encryption)
      final noteData = {
        'user_id': userId,
        'title': note.title,
        'content': note.content,
        'created_at': Timestamp.fromDate(note.createdAt),
        'updated_at': Timestamp.fromDate(note.updatedAt),
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

      return Note(
        id: doc.id,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
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
