import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteStorage {
  static const String _notesKey = 'notes';

  // Get all notes
  Future<List<Note>> getNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);

      if (notesJson == null) {
        return [];
      }

      final List<dynamic> notesList = json.decode(notesJson);
      return notesList.map((noteJson) => Note.fromJson(noteJson)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      return [];
    }
  }

  // Save a note
  Future<bool> saveNote(Note note) async {
    try {
      final notes = await getNotes();
      final existingIndex = notes.indexWhere((n) => n.id == note.id);

      if (existingIndex >= 0) {
        notes[existingIndex] = note;
      } else {
        notes.add(note);
      }

      final prefs = await SharedPreferences.getInstance();
      final notesJson = json.encode(notes.map((n) => n.toJson()).toList());
      return await prefs.setString(_notesKey, notesJson);
    } catch (e) {
      return false;
    }
  }

  // Delete a note
  Future<bool> deleteNote(String id) async {
    try {
      final notes = await getNotes();
      notes.removeWhere((note) => note.id == id);

      final prefs = await SharedPreferences.getInstance();
      final notesJson = json.encode(notes.map((n) => n.toJson()).toList());
      return await prefs.setString(_notesKey, notesJson);
    } catch (e) {
      return false;
    }
  }

  // Get a single note by ID
  Future<Note?> getNoteById(String id) async {
    try {
      final notes = await getNotes();
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}
