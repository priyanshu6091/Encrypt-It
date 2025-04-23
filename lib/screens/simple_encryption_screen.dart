import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/encryption_service.dart';

class SimpleEncryptionScreen extends StatefulWidget {
  const SimpleEncryptionScreen({Key? key}) : super(key: key);

  @override
  State<SimpleEncryptionScreen> createState() => _SimpleEncryptionScreenState();
}

class _SimpleEncryptionScreenState extends State<SimpleEncryptionScreen>
    with SingleTickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();
  final _outputController = TextEditingController();
  final _encryptionService = EncryptionService();
  bool _isEncrypting = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  void _processText() async {
    final text = _inputController.text;
    final password = _passwordController.text;

    if (text.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Text and password cannot be empty'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String result;
      // Simulate a delay to show the loading indicator (encryption is actually very fast)
      await Future.delayed(const Duration(milliseconds: 500));

      if (_isEncrypting) {
        result = _encryptionService.encryptText(text, password);
      } else {
        result = _encryptionService.decryptText(text, password);
      }

      // Close loading dialog
      Navigator.of(context).pop();

      setState(() {
        _outputController.text = result;
      });

      // Play success animation
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _outputController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _clearFields() {
    setState(() {
      _inputController.clear();
      _passwordController.clear();
      _outputController.clear();
    });
  }

  void _toggleMode() {
    setState(() {
      _isEncrypting = !_isEncrypting;
      _outputController.clear();
    });

    // Animate the mode change
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEncrypting ? 'Secure Encryption' : 'Secure Decryption',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed:
                _outputController.text.isNotEmpty ? _copyToClipboard : null,
            tooltip: 'Copy to clipboard',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearFields,
            tooltip: 'Clear all fields',
          ),
          // Modified actions menu without Firebase-dependent options
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'notes',
                    child: Row(
                      children: [
                        Icon(Icons.note),
                        SizedBox(width: 8),
                        Text('Encrypted Notes'),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'notes') {
                Navigator.of(
                  context,
                ).pushNamed('/home', arguments: 'default_password');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isLightMode
                    ? [Colors.white, Colors.grey.shade100]
                    : [
                      Theme.of(context).colorScheme.background,
                      const Color(0xFF1A1A1A),
                    ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Icon
                Center(
                  child: Hero(
                    tag:
                        'encryption_app_logo', // Changed from 'app_logo' to avoid conflicts
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _isEncrypting
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        _isEncrypting ? Icons.lock : Icons.lock_open,
                        size: 48,
                        color:
                            _isEncrypting
                                ? colorScheme.primary
                                : colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mode selector
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color:
                            isLightMode
                                ? Colors.grey.withOpacity(0.2)
                                : Colors.black26,
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text(
                          'Encrypt',
                          style: TextStyle(
                            fontWeight:
                                _isEncrypting
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        icon: Icon(
                          Icons.lock,
                          color: _isEncrypting ? colorScheme.primary : null,
                        ),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text(
                          'Decrypt',
                          style: TextStyle(
                            fontWeight:
                                !_isEncrypting
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        icon: Icon(
                          Icons.lock_open,
                          color: !_isEncrypting ? colorScheme.secondary : null,
                        ),
                      ),
                    ],
                    selected: {_isEncrypting},
                    onSelectionChanged: (selected) {
                      _toggleMode();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.selected)) {
                            return isLightMode
                                ? Colors.white
                                : Theme.of(context).colorScheme.surface;
                          }
                          return isLightMode
                              ? Colors.grey.shade100
                              : Theme.of(context).colorScheme.surfaceVariant;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Input text field with animation
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _animation.value) * 20),
                      child: Opacity(opacity: _animation.value, child: child),
                    );
                  },
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      labelText:
                          _isEncrypting
                              ? 'Text to encrypt'
                              : 'Ciphertext to decrypt',
                      hintText:
                          _isEncrypting
                              ? 'Enter the message you want to encrypt'
                              : 'Enter the encrypted text you want to decrypt',
                      prefixIcon: Icon(
                        _isEncrypting ? Icons.text_fields : Icons.code,
                        color:
                            _isEncrypting
                                ? colorScheme.primary
                                : colorScheme.secondary,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _inputController.clear(),
                      ),
                    ),
                    maxLines: 5,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // Password field with animation
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _animation.value) * 20),
                      child: Opacity(opacity: _animation.value, child: child),
                    );
                  },
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your secret key',
                      prefixIcon: Icon(
                        Icons.password,
                        color:
                            _isEncrypting
                                ? colorScheme.primary
                                : colorScheme.secondary,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _passwordController.clear(),
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Process button with animation
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * _animation.value),
                      child: Opacity(opacity: _animation.value, child: child),
                    );
                  },
                  child: ElevatedButton.icon(
                    onPressed: _processText,
                    icon: Icon(_isEncrypting ? Icons.lock : Icons.lock_open),
                    label: Text(
                      _isEncrypting ? 'ENCRYPT IT' : 'DECRYPT IT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isEncrypting
                              ? colorScheme.primary
                              : colorScheme.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Result label
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Opacity(opacity: _animation.value, child: child);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.output,
                        size: 20,
                        color:
                            _isEncrypting
                                ? colorScheme.primary
                                : colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Result:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Output text field with animation
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _animation.value) * 20),
                        child: Opacity(opacity: _animation.value, child: child),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isLightMode
                                    ? Colors.grey.withOpacity(0.2)
                                    : Colors.black26,
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _outputController,
                        decoration: InputDecoration(
                          labelText: 'Output',
                          hintText:
                              _isEncrypting
                                  ? 'Encrypted text will appear here'
                                  : 'Decrypted text will appear here',
                          prefixIcon: Icon(
                            Icons.output,
                            color:
                                _isEncrypting
                                    ? colorScheme.primary
                                    : colorScheme.secondary,
                          ),
                          suffixIcon:
                              _outputController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: _copyToClipboard,
                                    tooltip: 'Copy to clipboard',
                                  )
                                  : null,
                        ),
                        readOnly: true,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    _outputController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
