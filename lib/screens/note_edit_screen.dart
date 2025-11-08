import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/note_storage.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final NoteStorage _noteStorage;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteStorage = NoteStorage(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      // Don't save empty notes
      Navigator.pop(context, false);
      return;
    }

    final now = DateTime.now();
    final isUpdate = widget.note != null;
    final note = isUpdate
        ? widget.note!.copyWith(
            title: title.isEmpty ? 'Untitled' : title,
            content: content,
            updatedAt: now,
          )
        : Note(
            id: '', // Empty ID for new notes - Firestore will generate it
            title: title.isEmpty ? 'Untitled' : title,
            content: content,
            createdAt: now,
            updatedAt: now,
          );

    // Save note in background - returns immediately for instant UI response
    // With Firestore offline persistence, this saves instantly to local cache
    _noteStorage.saveNote(note, isUpdate: isUpdate);

    // Close screen IMMEDIATELY - no waiting for save to complete
    // The Firestore stream will automatically update the list when sync completes
    // Offline persistence ensures the save happens instantly locally
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _saveNote,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, 
                        color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Save',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isEditing && widget.note != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, 
                    size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Last updated: ${dateFormat.format(widget.note!.updatedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.2, end: 0, duration: 300.ms),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    autofocus: !isEditing,
                    decoration: InputDecoration(
                      hintText: 'Untitled',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[300],
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      height: 1.2,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: -0.1, end: 0, duration: 400.ms),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _contentController,
                    autofocus: isEditing,
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.grey[400],
                        height: 1.6,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      height: 1.8,
                      color: Colors.grey[800],
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    expands: false,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
