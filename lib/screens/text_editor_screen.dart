import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/encrypted_text.dart';
import '../services/encryption_service.dart';
import '../services/storage_service.dart';

class TextEditorScreen extends StatefulWidget {
  final EncryptedText? text;
  final String password;

  const TextEditorScreen({Key? key, this.text, required this.password})
    : super(key: key);

  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _encryptionService = EncryptionService();
  final _storageService = StorageService();
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.text != null;
    _loadText();
  }

  Future<void> _loadText() async {
    if (widget.text != null) {
      _titleController.text = widget.text!.title;
      try {
        final decryptedContent = _encryptionService.decryptText(
          widget.text!.encryptedContent,
          widget.password,
        );
        _contentController.text = decryptedContent;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error decrypting text: ${e.toString()}')),
        );
        Navigator.of(context).pop();
        return;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveText() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    final now = DateTime.now();
    final encryptedContent = _encryptionService.encryptText(
      _contentController.text,
      widget.password,
    );

    if (widget.text != null) {
      // Update existing text
      final updatedText = EncryptedText(
        id: widget.text!.id,
        title: _titleController.text,
        encryptedContent: encryptedContent,
        createdAt: widget.text!.createdAt,
        modifiedAt: now,
      );
      await _storageService.updateEncryptedText(updatedText);
    } else {
      // Create new text
      final newText = EncryptedText(
        id: const Uuid().v4(),
        title: _titleController.text,
        encryptedContent: encryptedContent,
        createdAt: now,
        modifiedAt: now,
      );
      await _storageService.addEncryptedText(newText);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Text' : 'New Text'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveText),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
