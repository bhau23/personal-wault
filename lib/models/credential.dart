class Credential {
  final int? id;
  final String title;
  final String category;
  final String? username;
  final String? email;
  final String? password;
  final String? url;
  final String? apiKey;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;

  Credential({
    this.id,
    required this.title,
    this.category = 'General',
    this.username,
    this.email,
    this.password,
    this.url,
    this.apiKey,
    this.notes,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'category': category,
        'username': username ?? '',
        'email': email ?? '',
        'password': password ?? '',
        'url': url ?? '',
        'api_key': apiKey ?? '',
        'notes': notes ?? '',
        'is_favorite': isFavorite ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory Credential.fromMap(Map<String, dynamic> map) => Credential(
        id: map['id'] as int?,
        title: map['title'] as String? ?? '',
        category: map['category'] as String? ?? 'General',
        username: _nullIfEmpty(map['username']),
        email: _nullIfEmpty(map['email']),
        password: _nullIfEmpty(map['password']),
        url: _nullIfEmpty(map['url']),
        apiKey: _nullIfEmpty(map['api_key']),
        notes: _nullIfEmpty(map['notes']),
        isFavorite: (map['is_favorite'] as int?) == 1,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  static String? _nullIfEmpty(dynamic val) {
    if (val == null) return null;
    final s = val.toString();
    return s.isEmpty ? null : s;
  }

  Credential copyWith({
    int? id,
    String? title,
    String? category,
    String? username,
    String? email,
    String? password,
    String? url,
    String? apiKey,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
  }) =>
      Credential(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        url: url ?? this.url,
        apiKey: apiKey ?? this.apiKey,
        notes: notes ?? this.notes,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
      );
}
