import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_item.dart';

class PasswordDetailScreen extends StatefulWidget {
  final PasswordItem password;

  const PasswordDetailScreen({
    super.key,
    required this.password,
  });

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  bool _isPasswordVisible = false;

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              title: 'Title',
              content: widget.password.title,
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              title: 'Username',
              content: widget.password.username,
              icon: Icons.person,
              onCopy: () => _copyToClipboard(
                widget.password.username,
                'Username copied to clipboard',
              ),
            ),
            const SizedBox(height: 16),
            _buildPasswordCard(),
            if (widget.password.website != null) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                title: 'Website',
                content: widget.password.website!,
                icon: Icons.web,
                onCopy: () => _copyToClipboard(
                  widget.password.website!,
                  'Website copied to clipboard',
                ),
              ),
            ],
            if (widget.password.notes != null) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                title: 'Notes',
                content: widget.password.notes!,
                icon: Icons.notes,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(
                        widget.password.password,
                        'Password copied to clipboard',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isPasswordVisible
                  ? widget.password.password
                  : '•' * widget.password.password.length,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String content,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onCopy != null)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: onCopy,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
