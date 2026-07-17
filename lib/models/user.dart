class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  final int id;
  final String name;
  final String email;
  final List<String> roles;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
