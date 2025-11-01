class Organization {
  final int id;
  final String nombre;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.nombre,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      nombre: json['nombre'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
