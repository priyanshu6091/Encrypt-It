import 'package:flutter/material.dart';
import '../models/encrypted_text.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final String password;

  const HomeScreen({Key? key, required this.password}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<EncryptedText> _encryptedTexts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEncryptedTexts();
  }

  Future<void> _loadEncryptedTexts() async {
    final texts = await _storageService.loadEncryptedTexts();
    setState(() {
      _encryptedTexts = texts;
      _isLoading = false;
    });
  }

  Future<void> _deleteText(String id) async {
    await _storageService.deleteEncryptedText(id);
    _loadEncryptedTexts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encrypted Texts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navigate back to the encryption screen instead of login
              Navigator.of(context).pushReplacementNamed('/simple_encryption');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _encryptedTexts.isEmpty
              ? const Center(child: Text('No encrypted texts yet'))
              : ListView.builder(
                itemCount: _encryptedTexts.length,
                itemBuilder: (context, index) {
                  final text = _encryptedTexts[index];
                  return ListTile(
                    title: Text(text.title),
                    subtitle: Text(
                      'Modified: ${text.modifiedAt.toLocal().toString().split('.')[0]}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteText(text.id),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(
                            '/editor',
                            arguments: {
                              'text': text,
                              'password': widget.password,
                            },
                          )
                          .then((_) => _loadEncryptedTexts());
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .pushNamed('/editor', arguments: {'password': widget.password})
              .then((_) => _loadEncryptedTexts());
        },
      ),
    );
  }
}
