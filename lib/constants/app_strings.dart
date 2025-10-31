import 'package:flutter/material.dart';

// Abstract class for all app strings
abstract class AppStrings {
  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'es' ? EsStrings() : EnStrings();
  }

  // Common
  String get save;
  String get cancel;
  String get delete;
  String get actions;
  String get status;
  String get type;
  String get brand;
  String get name;
  String get description;
  String get date;
  String get allStatuses;
  String get allTypes;
  String get allBrands;

  // Login & Registration
  String get welcomeBack;
  String get signInToContinue;
  String get username;
  String get pleaseEnterUsername;
  String get password;
  String get pleaseEnterPassword;
  String get logIn;
  String get loggingIn;
  String get noAccount;
  String get createAccount;
  String get signUpToGetStarted;
  String get email;
  String get pleaseEnterEmail;
  String get confirmPassword;
  String get pleaseConfirmPassword;
  String get passwordsDoNotMatch;
  String get signUp;
  String get signingUp;
  String get alreadyHaveAccount;

  // Dashboard & Settings
  String get dashboard;
  String get equipmentManagement;
  String get technicianManagement;
  String get maintenancePlanning;
  String get taskManagement;
  String get reports;
  String get settings;
  String get userManagement;
  String get systemParameters;
  String get auditLog;
  String get logout;
  String get darkMode;
  String get language;

  // Equipment
  String get equipments;
  String get addEquipment;
  String get searchEquipments;
  String get equipmentName;
  String get assetCode;
  String get organizationId;
  String get lastMaintenanceShort;
  String get nextMaintenanceShort;
  String get characteristics;
  String get registerEditEquipment;
  String get so;
  String get hostname;
  String get processor;
  String get ram;
  String get storage;
  String get unit;

  // Technicians
  String get technicians;
  String get addTechnician;
  String get searchTechnicians;
  String get specialty;
  String get availability;
  String get allSpecialties;
  String get registerEditTechnician;

  // Maintenances
  String get maintenances;
  String get addMaintenance;
  String get searchMaintenances;
  String get scheduleMaintenance;
  String get equipment;
  String get technician;
  String get maintenanceType;

  // Tasks
  String get tasks;
  String get addTask;
  String get searchTasks;
  String get taskTemplates;
  String get taskDescription;
  String get editTaskTemplate;
  String get addTaskTemplate;
  String get deleteTaskTemplate;
  String get deleteTaskConfirmation;
  String get registerEditTask;
  String get responsibleTechnician;
  String get taskState;
  String get taskDate;
  String get observations;
  
  // Reports
  String get generateReport;
  String get reportPreview;
  String get datasheetReport;
  String get exportToPDF;
}

// English Implementations
class EnStrings implements AppStrings {
  // Common
  @override String get save => 'Save';
  @override String get cancel => 'Cancel';
  @override String get delete => 'Delete';
  @override String get actions => 'Actions';
  @override String get status => 'Status';
  @override String get type => 'Type';
  @override String get brand => 'Brand';
  @override String get name => 'Name';
  @override String get description => 'Description';
  @override String get date => 'Date';
  @override String get allStatuses => 'All Statuses';
  @override String get allTypes => 'All Types';
  @override String get allBrands => 'All Brands';
  
  // Login & Registration
  @override String get welcomeBack => 'Welcome Back!';
  @override String get signInToContinue => 'Sign in to continue to Endetech';
  @override String get username => 'Username';
  @override String get pleaseEnterUsername => 'Please enter your username';
  @override String get password => 'Password';
  @override String get pleaseEnterPassword => 'Please enter your password';
  @override String get logIn => 'Log In';
  @override String get loggingIn => 'Logging in...';
  @override String get noAccount => 'Don\'t have an account? Sign up';
  @override String get createAccount => 'Create Account';
  @override String get signUpToGetStarted => 'Sign up to get started.';
  @override String get email => 'Email';
  @override String get pleaseEnterEmail => 'Please enter your email';
  @override String get confirmPassword => 'Confirm Password';
  @override String get pleaseConfirmPassword => 'Please confirm your password';
  @override String get passwordsDoNotMatch => 'Passwords do not match';
  @override String get signUp => 'Sign Up';
  @override String get signingUp => 'Signing up...';
  @override String get alreadyHaveAccount => 'Already have an account? Log in';

  // Dashboard & Settings
  @override String get dashboard => 'Dashboard';
  @override String get equipmentManagement => 'Equipment Management';
  @override String get technicianManagement => 'Technician Management';
  @override String get maintenancePlanning => 'Maintenance Planning';
  @override String get taskManagement => 'Task Management';
  @override String get reports => 'Reports';
  @override String get settings => 'Settings';
  @override String get userManagement => 'User/Role Management';
  @override String get systemParameters => 'System Parameters';
  @override String get auditLog => 'Audit Log';
  @override String get logout => 'Logout';
  @override String get darkMode => 'Dark Mode';
  @override String get language => 'Language';

  // Equipment
  @override String get equipments => 'Equipments';
  @override String get addEquipment => 'Add Equipment';
  @override String get searchEquipments => 'Search equipment...';
  @override String get equipmentName => 'Equipment Name';
  @override String get assetCode => 'Asset Code';
  @override String get organizationId => 'Org. ID';
  @override String get lastMaintenanceShort => 'Last Maint.';
  @override String get nextMaintenanceShort => 'Next Maint.';
  @override String get characteristics => 'Characteristics';
  @override String get registerEditEquipment => 'Register/Edit Equipment';
  @override String get so => 'Operating System';
  @override String get hostname => 'Hostname';
  @override String get processor => 'Processor';
  @override String get ram => 'RAM';
  @override String get storage => 'Storage';
  @override String get unit => 'Unit';

  // Technicians
  @override String get technicians => 'Técnicos';
  @override String get addTechnician => 'Añadir Técnico';
  @override String get searchTechnicians => 'Buscar técnicos...';
  @override String get specialty => 'Especialidad';
  @override String get availability => 'Disponibilidad';
  @override String get allSpecialties => 'Todas las Especialidades';
  @override String get registerEditTechnician => 'Registrar/Editar Técnico';
  
  // Maintenances
  @override String get maintenances => 'Mantenimientos';
  @override String get addMaintenance => 'Añadir Mantenimiento';
  @override String get searchMaintenances => 'Buscar mantenimientos...';
  @override String get scheduleMaintenance => 'Programar Mantenimiento';
  @override String get equipment => 'Equipo';
  @override String get technician => 'Técnico';
  @override String get maintenanceType => 'Tipo de Mantenimiento';
  
  // Tasks
  @override String get tasks => 'Tareas';
  @override String get addTask => 'Añadir Tarea';
  @override String get searchTasks => 'Buscar tareas...';
  @override String get taskTemplates => 'Plantillas de Tareas';
  @override String get taskDescription => 'Descripción de la Tarea';
  @override String get editTaskTemplate => 'Editar Tarea';
  @override String get addTaskTemplate => 'Añadir Tarea';
  @override String get deleteTaskTemplate => 'Eliminar Tarea';
  @override String get deleteTaskConfirmation => '¿Estás seguro de que quieres eliminar esta tarea?';
  @override String get registerEditTask => 'Registrar/Editar Tarea';
  @override String get responsibleTechnician => 'Técnico Responsable';
  @override String get taskState => 'Estado';
  @override String get taskDate => 'Fecha';
  @override String get observations => 'Observaciones';

  // Reports
  @override String get generateReport => 'Generar Informe';
  @override String get reportPreview => 'Vista Previa del Informe';
  @override String get datasheetReport => 'Informe de Ficha Técnica';
  @override String get exportToPDF => 'Exportar a PDF';
}

// Spanish Implementations
class EsStrings implements AppStrings {
  // Common
  @override String get save => 'Guardar';
  @override String get cancel => 'Cancelar';
  @override String get delete => 'Eliminar';
  @override String get actions => 'Acciones';
  @override String get status => 'Estado';
  @override String get type => 'Tipo';
  @override String get brand => 'Marca';
  @override String get name => 'Nombre';
  @override String get description => 'Descripción';
  @override String get date => 'Fecha';
  @override String get allStatuses => 'Todos los Estados';
  @override String get allTypes => 'Todos los Tipos';
  @override String get allBrands => 'Todas las Marcas';
  
  // Login & Registration
  @override String get welcomeBack => '¡Bienvenido de nuevo!';
  @override String get signInToContinue => 'Inicia sesión para continuar en Endetech';
  @override String get username => 'Usuario';
  @override String get pleaseEnterUsername => 'Por favor, introduce tu usuario';
  @override String get password => 'Contraseña';
  @override String get pleaseEnterPassword => 'Por favor, introduce tu contraseña';
  @override String get logIn => 'Iniciar Sesión';
  @override String get loggingIn => 'Iniciando sesión...';
  @override String get noAccount => '¿No tienes una cuenta? Regístrate';
  @override String get createAccount => 'Crear Cuenta';
  @override String get signUpToGetStarted => 'Regístrate para empezar.';
  @override String get email => 'Correo Electrónico';
  @override String get pleaseEnterEmail => 'Por favor, introduce tu correo';
  @override String get confirmPassword => 'Confirmar Contraseña';
  @override String get pleaseConfirmPassword => 'Por favor, confirma tu contraseña';
  @override String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
  @override String get signUp => 'Registrarse';
  @override String get signingUp => 'Registrando...';
  @override String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';
  
  // Dashboard & Settings
  @override String get dashboard => 'Panel Principal';
  @override String get equipmentManagement => 'Gestión de Equipos';
  @override String get technicianManagement => 'Gestión de Técnicos';
  @override String get maintenancePlanning => 'Planificación de Mant.';
  @override String get taskManagement => 'Gestión de Tareas';
  @override String get reports => 'Informes';
  @override String get settings => 'Configuración';
  @override String get userManagement => 'Gestión de Usuarios/Roles';
  @override String get systemParameters => 'Parámetros del Sistema';
  @override String get auditLog => 'Registro de Auditoría';
  @override String get logout => 'Cerrar Sesión';
  @override String get darkMode => 'Modo Oscuro';
  @override String get language => 'Idioma';

  // Equipment
  @override String get equipments => 'Equipos';
  @override String get addEquipment => 'Añadir Equipo';
  @override String get searchEquipments => 'Buscar equipo...';
  @override String get equipmentName => 'Nombre del Equipo';
  @override String get assetCode => 'Cód. Activo';
  @override String get organizationId => 'ID Org.';
  @override String get lastMaintenanceShort => 'Últ. Mant.';
  @override String get nextMaintenanceShort => 'Sig. Mant.';
  @override String get characteristics => 'Características';
  @override String get registerEditEquipment => 'Registrar/Editar Equipo';
  @override String get so => 'Sistema Operativo';
  @override String get hostname => 'Hostname';
  @override String get processor => 'Procesador';
  @override String get ram => 'RAM';
  @override String get storage => 'Almacenamiento';
  @override String get unit => 'Unidad';

  // Technicians
  @override String get technicians => 'Técnicos';
  @override String get addTechnician => 'Añadir Técnico';
  @override String get searchTechnicians => 'Buscar técnicos...';
  @override String get specialty => 'Especialidad';
  @override String get availability => 'Disponibilidad';
  @override String get allSpecialties => 'Todas las Especialidades';
  @override String get registerEditTechnician => 'Registrar/Editar Técnico';
  
  // Maintenances
  @override String get maintenances => 'Mantenimientos';
  @override String get addMaintenance => 'Añadir Mantenimiento';
  @override String get searchMaintenances => 'Buscar mantenimientos...';
  @override String get scheduleMaintenance => 'Programar Mantenimiento';
  @override String get equipment => 'Equipo';
  @override String get technician => 'Técnico';
  @override String get maintenanceType => 'Tipo de Mantenimiento';
  
  // Tasks
  @override String get tasks => 'Tareas';
  @override String get addTask => 'Añadir Tarea';
  @override String get searchTasks => 'Buscar tareas...';
  @override String get taskTemplates => 'Plantillas de Tareas';
  @override String get taskDescription => 'Descripción de la Tarea';
  @override String get editTaskTemplate => 'Editar Tarea';
  @override String get addTaskTemplate => 'Añadir Tarea';
  @override String get deleteTaskTemplate => 'Eliminar Tarea';
  @override String get deleteTaskConfirmation => '¿Estás seguro de que quieres eliminar esta tarea?';
  @override String get registerEditTask => 'Registrar/Editar Tarea';
  @override String get responsibleTechnician => 'Técnico Responsable';
  @override String get taskState => 'Estado';
  @override String get taskDate => 'Fecha';
  @override String get observations => 'Observaciones';

  // Reports
  @override String get generateReport => 'Generar Informe';
  @override String get reportPreview => 'Vista Previa del Informe';
  @override String get datasheetReport => 'Informe de Ficha Técnica';
  @override String get exportToPDF => 'Exportar a PDF';
}
