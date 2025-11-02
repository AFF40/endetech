import 'package:endetech/models/organization.dart';

class Equipment {
  final int id;
  final String codigo;
  final String nombre;
  final String tipo;
  final String marca;
  final Organization? organization;
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
    this.organization,
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
    final orgData = json['organization'] ?? json['organizacion'];
    return Equipment(
      id: json['id'],
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      marca: json['marca'] ?? '',
      organization: orgData != null && orgData is Map<String, dynamic>
          ? Organization.fromJson(orgData)
          : null,
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

  Equipment copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? tipo,
    String? marca,
    Organization? organization,
    String? sistemaOperativo,
    String? procesador,
    String? memoriaRam,
    String? almacenamiento,
    DateTime? ultimoMantenimiento,
    DateTime? proximoMantenimiento,
    String? estado,
  }) {
    return Equipment(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      organization: organization ?? this.organization,
      sistemaOperativo: sistemaOperativo ?? this.sistemaOperativo,
      procesador: procesador ?? this.procesador,
      memoriaRam: memoriaRam ?? this.memoriaRam,
      almacenamiento: almacenamiento ?? this.almacenamiento,
      ultimoMantenimiento: ultimoMantenimiento ?? this.ultimoMantenimiento,
      proximoMantenimiento: proximoMantenimiento ?? this.proximoMantenimiento,
      estado: estado ?? this.estado,
    );
  }
}
