class Organization {
  final int id;
  final String nombre;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Organization({
    required this.id,
    required this.nombre,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      nombre: json['nombre'] ?? 'Sin nombre', // Handle null name
      description: json['descripcion'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
