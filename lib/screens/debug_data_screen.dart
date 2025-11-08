import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/rsa_encryption.dart';

class DebugDataScreen extends StatefulWidget {
  const DebugDataScreen({super.key});

  @override
  State<DebugDataScreen> createState() => _DebugDataScreenState();
}

class _DebugDataScreenState extends State<DebugDataScreen> {
  final RSAEncryption _encryption = RSAEncryption();
  bool _showEncrypted = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Database Data Viewer',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showEncrypted ? Icons.lock_outline : Icons.lock_open),
            onPressed: () {
              setState(() {
                _showEncrypted = !_showEncrypted;
              });
            },
            tooltip: _showEncrypted ? 'Show Decrypted' : 'Show Encrypted',
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current User',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text('User ID: $userId', style: GoogleFonts.inter()),
                Text('Email: ${user?.email ?? "N/A"}', style: GoogleFonts.inter()),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notes')
                  .where('user_id', isEqualTo: userId)
                  .orderBy('updated_at', descending: true)
                  .snapshots(),
                  builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No notes found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final notes = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final doc = notes[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Document ID:',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Text(
                                  doc.id,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Show encrypted data
                            if (_showEncrypted && data['encrypted_title'] != null)
                              _buildDataRow('Encrypted Title', data['encrypted_title'] ?? 'N/A'),
                            if (_showEncrypted && data['encrypted_title'] != null) const SizedBox(height: 8),
                            if (_showEncrypted && data['encrypted_content'] != null)
                              _buildDataRow('Encrypted Content', 
                                '${(data['encrypted_content'] ?? '').toString().substring(0, 50)}...'),
                            if (_showEncrypted && data['encrypted_content'] != null) const SizedBox(height: 8),
                            // Show decrypted data
                            if (!_showEncrypted)
                              FutureBuilder<String>(
                                future: _decryptField(data['encrypted_title']),
                                builder: (context, titleSnapshot) {
                                  return _buildDataRow(
                                    'Title (Decrypted)',
                                    titleSnapshot.data ?? 'Decrypting...',
                                  );
                                },
                              ),
                            if (!_showEncrypted) const SizedBox(height: 8),
                            if (!_showEncrypted)
                              FutureBuilder<String>(
                                future: _decryptField(data['encrypted_content']),
                                builder: (context, contentSnapshot) {
                                  return _buildDataRow(
                                    'Content (Decrypted)',
                                    contentSnapshot.data ?? 'Decrypting...',
                                  );
                                },
                              ),
                            if (!_showEncrypted) const SizedBox(height: 8),
                            // Fallback to plain text if no encryption
                            if ((data['encrypted_title'] == null || data['encrypted_title'].toString().isEmpty) &&
                                (data['title'] != null && data['title'].toString().isNotEmpty))
                              _buildDataRow('Title (Plain Text)', data['title'] ?? 'N/A'),
                            if ((data['encrypted_title'] == null || data['encrypted_title'].toString().isEmpty) &&
                                (data['title'] != null && data['title'].toString().isNotEmpty))
                              const SizedBox(height: 8),
                            if ((data['encrypted_content'] == null || data['encrypted_content'].toString().isEmpty) &&
                                (data['content'] != null && data['content'].toString().isNotEmpty))
                              _buildDataRow('Content (Plain Text)', data['content'] ?? 'N/A'),
                            if ((data['encrypted_content'] == null || data['encrypted_content'].toString().isEmpty) &&
                                (data['content'] != null && data['content'].toString().isNotEmpty))
                              const SizedBox(height: 8),
                            _buildDataRow(
                              'User ID',
                              data['user_id'] ?? 'N/A',
                            ),
                            const SizedBox(height: 8),
                            _buildDataRow(
                              'Created At',
                              data['created_at'] != null
                                  ? (data['created_at'] as Timestamp)
                                      .toDate()
                                      .toString()
                                  : 'N/A',
                            ),
                            const SizedBox(height: 8),
                            _buildDataRow(
                              'Updated At',
                              data['updated_at'] != null
                                  ? (data['updated_at'] as Timestamp)
                                      .toDate()
                                      .toString()
                                  : 'N/A',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _decryptField(dynamic encryptedData) async {
    if (encryptedData == null || encryptedData.toString().isEmpty) {
      return 'N/A';
    }
    try {
      return await _encryption.decryptLargeText(encryptedData.toString());
    } catch (e) {
      return 'Decryption Error: $e';
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }
}

