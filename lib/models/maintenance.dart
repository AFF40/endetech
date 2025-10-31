class Maintenance {
  const Maintenance({
    required this.equipment,
    required this.technician,
    required this.type,
    required this.date,
    required this.status,
  });

  final String equipment;
  final String technician;
  final String type;
  final DateTime date;
  final String status;
}
