class Technician {
  final int id;
  final String nombre;
  final String primerApellido;
  final String? segundoApellido; // Nullable
  final String especialidad;

  Technician({
    required this.id,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.especialidad,
  });

  // Helper to get full name
  String get fullName {
    return '$nombre $primerApellido ${segundoApellido ?? ''}'.trim();
  }

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'],
      nombre: json['nombre'],
      primerApellido: json['primer_apellido'],
      segundoApellido: json['segundo_apellido'], // This can be null
      especialidad: json['especialidad'],
    );
  }
}
