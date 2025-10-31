class Equipment {
  const Equipment({
    required this.assetCode,
    required this.name,
    required this.type,
    required this.brand,
    required this.organizationId,
    required this.status,
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.characteristics, // New field
  });

  final String assetCode;
  final String name;
  final String type;
  final String brand;
  final String organizationId;
  final String status;
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
  final String characteristics; // New field
}
