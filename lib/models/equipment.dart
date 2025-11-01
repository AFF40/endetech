class Equipment {
  final int id;
  final String codigo;
  final String nombre;
  final String tipo;
  final String marca;
  final int? organizationId;
  final String? sistemaOperativo;
  final String? procesador;
  final String? memoriaRam;
  final String? almacenamiento;
  final DateTime? ultimoMantenimiento;
  final DateTime? proximoMantenimiento;
  final String estado;

  Equipment({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    required this.marca,
    this.organizationId,
    this.sistemaOperativo,
    this.procesador,
    this.memoriaRam,
    this.almacenamiento,
    this.ultimoMantenimiento,
    this.proximoMantenimiento,
    required this.estado,
  });

  String get characteristics {
    return 'SO: ${sistemaOperativo ?? 'N/A'}\n'
           'CPU: ${procesador ?? 'N/A'}\n'
           'RAM: ${memoriaRam ?? 'N/A'}\n'
           'Storage: ${almacenamiento ?? 'N/A'}';
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      marca: json['marca'] ?? '',
      organizationId: json['organization_id'],
      sistemaOperativo: json['sistema_operativo'],
      procesador: json['procesador'],
      memoriaRam: json['memoria_ram'],
      almacenamiento: json['almacenamiento'],
      ultimoMantenimiento: json['ultimo_mantenimiento'] == null
          ? null
          : DateTime.parse(json['ultimo_mantenimiento']),
      proximoMantenimiento: json['proximo_mantenimiento'] == null
          ? null
          : DateTime.parse(json['proximo_mantenimiento']),
      estado: json['estado'] ?? '',
    );
  }
}
