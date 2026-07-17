/// A small {id, name} reference used for nested relations & lookups.
class NamedRef {
  NamedRef({required this.id, required this.name, this.companyId});

  final int id;
  final String name;
  final int? companyId;

  factory NamedRef.fromJson(Map<String, dynamic> json) {
    return NamedRef(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '-',
      companyId: json['company_id'] as int?,
    );
  }

  @override
  bool operator ==(Object other) => other is NamedRef && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
