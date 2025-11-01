class Task {
  final int id;
  final String nombre;
  final String descripcion;

  Task({required this.id, required this.nombre, required this.descripcion});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }
}
