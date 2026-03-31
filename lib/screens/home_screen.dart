import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/credential.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'add_edit_screen.dart';

const defaultCategories = [
  'All',
  'AI & API Keys',
  'Social Media',
  'Email',
  'Cloud Services',
  'Development',
  'Finance',
  'General',
];

class HomeScreen extends StatefulWidget {
  final VoidCallback onLock;
  const HomeScreen({super.key, required this.onLock});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirestoreService();
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _showFavorites = false;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore.setUser(user.uid);
    }
  }

  List<Credential> _filterCredentials(List<Credential> all) {
    var filtered = all;

    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((c) => c.category == _selectedCategory).toList();
    }
    if (_showFavorites) {
      filtered = filtered.where((c) => c.isFavorite).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((c) =>
              c.title.toLowerCase().contains(q) ||
              (c.username?.toLowerCase().contains(q) ?? false) ||
              (c.email?.toLowerCase().contains(q) ?? false) ||
              (c.url?.toLowerCase().contains(q) ?? false) ||
              (c.apiKey?.toLowerCase().contains(q) ?? false) ||
              (c.notes?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return filtered;
  }

  Future<void> _toggleFavorite(Credential cred) async {
    await _firestore.toggleFavorite(cred);
  }

  Future<void> _deleteCredential(Credential cred) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Credential'),
        content: Text('Delete "${cred.title}"? This cannot be undone.'),
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
    if (confirmed == true && cred.id != null) {
      await _firestore.deleteCredential(cred.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credential deleted')),
        );
      }
    }
  }

  void _openAddEdit({Credential? credential}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditScreen(credential: credential),
      ),
    );
    // No need to reload - StreamBuilder handles it automatically
  }

  void _copyToClipboard(String label, String? value) {
    if (value == null || value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  void _lock() {
    AuthService().lock();
    widget.onLock();
  }

  void _signOut() async {
    AuthService().lock();
    await FirebaseAuth.instance.signOut();
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'AI & API Keys':
        return Icons.key_rounded;
      case 'Social Media':
        return Icons.people_rounded;
      case 'Email':
        return Icons.email_rounded;
      case 'Cloud Services':
        return Icons.cloud_rounded;
      case 'Development':
        return Icons.code_rounded;
      case 'Finance':
        return Icons.account_balance_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search credentials...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Row(
                children: [
                  Icon(Icons.shield_rounded,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  const Text('Wault',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              _showFavorites
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _showFavorites ? Colors.redAccent : null,
            ),
            onPressed: () => setState(() => _showFavorites = !_showFavorites),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'lock') _lock();
              if (val == 'signout') _signOut();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'lock',
                child: ListTile(
                  leading: Icon(Icons.lock_outline_rounded),
                  title: Text('Lock Vault'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Sign Out'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: defaultCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = defaultCategories[i];
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  avatar:
                      isSelected ? null : Icon(_categoryIcon(cat), size: 16),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Real-time credential list from Firestore
          Expanded(
            child: StreamBuilder<List<Credential>>(
              stream: _firestore.watchCredentials(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('Failed to load credentials',
                            style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 4),
                        Text('${snapshot.error}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white38)),
                      ],
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final filtered = _filterCredentials(all);

                if (filtered.isEmpty) {
                  return _buildEmptyState(theme, all.isEmpty);
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _buildCredentialCard(filtered[i], theme),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool vaultEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined,
              size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            vaultEmpty
                ? 'Your vault is empty'
                : _showFavorites
                    ? 'No favorites yet'
                    : 'No credentials in this category',
            style:
                theme.textTheme.titleMedium?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first credential',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white30),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(Credential cred, ThemeData theme) {
    final hasPassword = cred.password != null && cred.password!.isNotEmpty;
    final hasApiKey = cred.apiKey != null && cred.apiKey!.isNotEmpty;
    final subtitle = cred.username ?? cred.email ?? cred.url ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openAddEdit(credential: cred),
        onLongPress: () => _deleteCredential(cred),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon(cred.category),
                    color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cred.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        cred.category,
                        style: TextStyle(
                            fontSize: 11, color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _toggleFavorite(cred),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        cred.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color:
                            cred.isFavorite ? Colors.redAccent : Colors.white30,
                      ),
                    ),
                  ),
                  if (hasPassword)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          _copyToClipboard('Password', cred.password),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.copy_rounded,
                            size: 18, color: Colors.white30),
                      ),
                    )
                  else if (hasApiKey)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          _copyToClipboard('API Key', cred.apiKey),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.copy_rounded,
                            size: 18, color: Colors.white30),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
