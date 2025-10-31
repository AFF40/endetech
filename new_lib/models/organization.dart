class Organization {
  final String nombre;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.nombre,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      nombre: json['nombre'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
