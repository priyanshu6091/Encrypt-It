import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/encrypted_text.dart';

class StorageService {
  final String _storageKey = 'encrypted_texts';

  // Save encrypted text entries
  Future<void> saveEncryptedTexts(List<EncryptedText> texts) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTexts =
        texts.map((text) => jsonEncode(text.toJson())).toList();
    await prefs.setStringList(_storageKey, encodedTexts);
  }

  // Load encrypted text entries
  Future<List<EncryptedText>> loadEncryptedTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTexts = prefs.getStringList(_storageKey) ?? [];

    return encodedTexts
        .map((text) => EncryptedText.fromJson(jsonDecode(text)))
        .toList();
  }

  // Add a new encrypted text entry
  Future<void> addEncryptedText(EncryptedText text) async {
    final texts = await loadEncryptedTexts();
    texts.add(text);
    await saveEncryptedTexts(texts);
  }

  // Update an existing encrypted text entry
  Future<void> updateEncryptedText(EncryptedText updatedText) async {
    final texts = await loadEncryptedTexts();
    final index = texts.indexWhere((text) => text.id == updatedText.id);

    if (index >= 0) {
      texts[index] = updatedText;
      await saveEncryptedTexts(texts);
    }
  }

  // Delete an encrypted text entry
  Future<void> deleteEncryptedText(String id) async {
    final texts = await loadEncryptedTexts();
    texts.removeWhere((text) => text.id == id);
    await saveEncryptedTexts(texts);
  }
}
