import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/credential.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import 'home_screen.dart' show defaultCategories;

class AddEditScreen extends StatefulWidget {
  final Credential? credential;
  const AddEditScreen({super.key, this.credential});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _apiKeyCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  bool _obscurePassword = true;
  bool _obscureApiKey = true;
  bool _isSaving = false;

  bool get isEditing => widget.credential != null;

  // Categories excluding 'All'
  List<String> get _categories =>
      defaultCategories.where((c) => c != 'All').toList();

  @override
  void initState() {
    super.initState();
    final c = widget.credential;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _usernameCtrl = TextEditingController(text: c?.username ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _passwordCtrl = TextEditingController(text: c?.password ?? '');
    _urlCtrl = TextEditingController(text: c?.url ?? '');
    _apiKeyCtrl = TextEditingController(text: c?.apiKey ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');
    _category = c?.category ?? 'General';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final cred = Credential(
      id: widget.credential?.id,
      title: _titleCtrl.text.trim(),
      category: _category,
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      isFavorite: widget.credential?.isFavorite ?? false,
      createdAt: widget.credential?.createdAt,
    );

    if (isEditing) {
      await _db.updateCredential(cred);
    } else {
      await _db.insertCredential(cred);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    if (widget.credential == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Credential'),
        content: Text(
            'Delete "${widget.credential!.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteCredential(widget.credential!.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  void _generatePassword() {
    final password = EncryptionService.generatePassword();
    _passwordCtrl.text = password;
    setState(() => _obscurePassword = false);
  }

  void _copyField(String label, String value) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Credential' : 'Add Credential'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.label_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _categories.contains(_category) ? _category : 'General',
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.folder_rounded),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val ?? 'General'),
            ),
            const SizedBox(height: 16),

            // Username
            TextFormField(
              controller: _usernameCtrl,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person_rounded),
                suffixIcon: _usernameCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () =>
                            _copyField('Username', _usernameCtrl.text),
                      )
                    : null,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_rounded),
                suffixIcon: _emailCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () =>
                            _copyField('Email', _emailCtrl.text),
                      )
                    : null,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    IconButton(
                      icon: const Icon(Icons.casino_rounded, size: 20),
                      tooltip: 'Generate password',
                      onPressed: _generatePassword,
                    ),
                    if (_passwordCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () =>
                            _copyField('Password', _passwordCtrl.text),
                      ),
                  ],
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // URL
            TextFormField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL',
                prefixIcon: Icon(Icons.link_rounded),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // API Key
            TextFormField(
              controller: _apiKeyCtrl,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_obscureApiKey
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                    if (_apiKeyCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () =>
                            _copyField('API Key', _apiKeyCtrl.text),
                      ),
                  ],
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                label: Text(isEditing ? 'Save Changes' : 'Add Credential'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
