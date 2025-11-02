import 'package:endetech/models/equipment.dart';
import 'package:endetech/models/task.dart';
import 'package:endetech/models/technician.dart';

class Maintenance {
  final int id;
  final DateTime fechaProgramada;
  final DateTime? fechaReal;
  final String? observaciones;
  final String estado;
  final Equipment? equipo; // Made nullable
  final Technician? tecnico; // Made nullable
  final List<Task> tareas;

  const Maintenance({
    required this.id,
    required this.fechaProgramada,
    this.fechaReal,
    this.observaciones,
    required this.estado,
    this.equipo, // Made nullable
    this.tecnico, // Made nullable
    required this.tareas,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'],
      fechaProgramada: DateTime.parse(json['fecha_programada']),
      fechaReal: json['fecha_real'] != null ? DateTime.parse(json['fecha_real']) : null,
      observaciones: json['observaciones'],
      estado: json['estado'],
      // Safely parse nested objects
      equipo: json['equipo'] != null && json['equipo'] is Map<String, dynamic> 
          ? Equipment.fromJson(json['equipo']) 
          : null,
      tecnico: json['tecnico'] != null && json['tecnico'] is Map<String, dynamic> 
          ? Technician.fromJson(json['tecnico']) 
          : null,
      tareas: json['tareas'] != null
          ? (json['tareas'] as List).map((taskJson) => Task.fromJson(taskJson)).toList()
          : [],
    );
  }

  Maintenance copyWith({
    int? id,
    DateTime? fechaProgramada,
    DateTime? fechaReal,
    String? observaciones,
    String? estado,
    Equipment? equipo,
    Technician? tecnico,
    List<Task>? tareas,
  }) {
    return Maintenance(
      id: id ?? this.id,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      fechaReal: fechaReal ?? this.fechaReal,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      equipo: equipo ?? this.equipo,
      tecnico: tecnico ?? this.tecnico,
      tareas: tareas ?? this.tareas,
    );
  }
}
