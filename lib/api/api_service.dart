class ApiService {
  // Replace with your actual backend URL
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // --- Endpoints ---

  // Auth (Assuming this is still valid, not in the provided list)
  static const String login = '$baseUrl/auth/login';

  // Users & Roles
  static const String users = '$baseUrl/users';
  static String userById(int id) => '$baseUrl/users/$id';
  static String updateUser(int id) => '$baseUrl/users/$id'; // POST for update
  static const String roles = '$baseUrl/roles';
  static String roleById(int id) => '$baseUrl/roles/$id';

  // Technicians (Tecnicos)
  static const String tecnicos = '$baseUrl/tecnicos';
  static String tecnicoById(int id) => '$baseUrl/tecnicos/$id';
  static String updateTecnico(int id) => '$baseUrl/tecnicos/$id'; // POST for update

  // Tasks (Tareas)
  static const String tareas = '$baseUrl/tareas';
  static String tareaById(int id) => '$baseUrl/tareas/$id';
  static String updateTarea(int id) => '$baseUrl/tareas/$id'; // POST for update

  // Equipments (Equipos)
  static const String equipos = '$baseUrl/equipos';
  static String equipoById(int id) => '$baseUrl/equipos/$id';
  static String updateEquipo(int id) => '$baseUrl/equipos/$id'; // POST for update

  // Maintenances (Mantenimientos)
  static const String mantenimientos = '$baseUrl/mantenimientos';
  static String mantenimientoById(int id) => '$baseUrl/mantenimientos/$id';
  static String updateMantenimiento(int id) => '$baseUrl/mantenimientos/$id'; // POST for update

  // Organizations
  static const String organizations = '$baseUrl/organizations';
  static String organizationById(int id) => '$baseUrl/organizations/$id';
  static String updateOrganization(int id) => '$baseUrl/organizations/$id'; // POST for update

  // Report Endpoints (Assuming these are still valid, not in the provided list)
  static const String equipmentReport = '$baseUrl/reports/equipment';
  static const String maintenanceReport = '$baseUrl/reports/maintenance';
}
