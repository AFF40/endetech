class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'https://your-backend-api.com/api';

  // --- Endpoints ---
  static const String login = '$baseUrl/auth/login';

  // Equipment Endpoints
  static const String equipments = '$baseUrl/equipments';
  static String equipmentById(int id) => '$baseUrl/equipments/$id';

  // Technician Endpoints
  static const String technicians = '$baseUrl/technicians';
  static String technicianById(int id) => '$baseUrl/technicians/$id';

  // Maintenance Endpoints
  static const String maintenances = '$baseUrl/maintenances';
  static String maintenanceById(int id) => '$baseUrl/maintenances/$id';

  // Task Endpoints
  static const String tasks = '$baseUrl/tasks';
  static String taskById(int id) => '$baseUrl/tasks/$id';

  // Report Endpoints
  static const String equipmentReport = '$baseUrl/reports/equipment';
  static const String maintenanceReport = '$baseUrl/reports/maintenance';
}
