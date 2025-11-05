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
  String get selectAll;
  String get confirmAction;
  String get confirm;
  String get edit;
  String get retry;
  String get noResultsFound;
  String get notAvailable;
  String get unassigned;
  String get statusUpdated;
  String get fieldIsRequired;
  String get errorLoadingData;
  String get unexpectedErrorOccurred;
  String get none;
  String get nameLabel;
  String get codeLabel;
  String get specialtyLabel;
  String get scheduledDateLabel;
  String get statusLabel;
  String get observationsLabel;

  // Parametrized
  String confirmDelete(String item);
  String generatePdfForN(int count, String item);

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
  String get pleaseEnterName;
  String get confirmPassword;
  String get pleaseConfirmPassword;
  String get passwordsDoNotMatch;
  String get signUp;
  String get signingUp;
  String get alreadyHaveAccount;
  String get continueAsGuest;
  String get registrationSuccess;
  String get start;

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
  String get organizationManagement;

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
  String get equipmentDeleted;
  String get equipmentUpdated;
  String get equipmentCreated;
  String get mustBeAValidNumber;
  String get pleaseSelectAnOrganization;

  // Technicians
  String get technicians;
  String get addTechnician;
  String get searchTechnicians;
  String get specialty;
  String get availability;
  String get allSpecialties;
  String get registerEditTechnician;
  String get technicianDeleted;
  String get technicianUpdated;
  String get technicianCreated;
  String get firstName;
  String get secondNameOptional;
  
  // Maintenances
  String get maintenances;
  String get addMaintenance;
  String get searchMaintenances;
  String get scheduleMaintenance;
  String get equipment;
  String get technician;
  String get maintenanceType;
  String get confirmCompleteMaintenance;
  String get markAsCompleted;
  String get completed;
  String get pending;
  String get maintenanceDeleted;
  String get maintenanceUpdated;
  String get maintenanceCreated;
  String get maintenanceDetailTitle;
  String get maintenanceDetailsNotFound;
  String get maintenanceDetails;
  String get pleaseSelectADate;
  String get pleaseSelectAnEquipment;
  String get pleaseSelectATechnician;

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
  String get noTasksAssigned;
  String get taskDeleted;
  String get taskUpdated;
  String get taskCreated;

  // Organizations
  String get organization;
  String get addOrganization;
  String get registerEditOrganization;
  String get deleteOrganizationConfirmation;
  String get organizationDeleted;
  String get organizationUpdated;
  String get organizationCreated;
  String get searchByName;
  String get organizationReport;
  String get pleaseEnterDescription;
  
  // Reports
  String get generateReport;
  String get reportPreview;
  String get datasheetReport;
  String get exportToPDF;
  String get maintenanceReport;
  String get dateRange;
  String get selectDateRange;
  String get allTechnicians;
  String get allEquipments;
  String get startDate;
  String get endDate;
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
  @override String get description => 'Descripcion';
  @override String get date => 'Date';
  @override String get allStatuses => 'All Statuses';
  @override String get allTypes => 'All Types';
  @override String get allBrands => 'All Brands';
  @override String get selectAll => 'Select All';
  @override String get confirmAction => 'Confirm Action';
  @override String get confirm => 'Confirm';
  @override String get edit => 'Edit';
  @override String get retry => 'Retry';
  @override String get noResultsFound => 'No results found';
  @override String get notAvailable => 'N/A';
  @override String get unassigned => 'Unassigned';
  @override String get statusUpdated => 'Status updated';
  @override String get fieldIsRequired => 'This field is required';
  @override String get errorLoadingData => 'Error loading data';
  @override String get unexpectedErrorOccurred => 'An unexpected error occurred';
  @override String get none => 'None';
  @override String get nameLabel => 'Name:';
  @override String get codeLabel => 'Code:';
  @override String get specialtyLabel => 'Specialty:';
  @override String get scheduledDateLabel => 'Scheduled Date:';
  @override String get statusLabel => 'Status:';
  @override String get observationsLabel => 'Observations:';

  // Parametrized
  @override String confirmDelete(String item) => 'Are you sure you want to delete ${item}?';
  @override String generatePdfForN(int count, String item) => 'Generate PDF for $count ${item}(s)';

  // Login & Registration
  @override String get welcomeBack => 'ENDETECH';
  @override String get signInToContinue => 'Start to continue to Endetech';
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
  @override String get pleaseEnterName => 'Please enter your name';
  @override String get confirmPassword => 'Confirm Password';
  @override String get pleaseConfirmPassword => 'Please confirm your password';
  @override String get passwordsDoNotMatch => 'Passwords do not match';
  @override String get signUp => 'Sign Up';
  @override String get signingUp => 'Signing up...';
  @override String get alreadyHaveAccount => 'Already have an account? Log in';
  @override String get continueAsGuest => 'Continue as Guest';
  @override String get registrationSuccess => 'Registration successful. Please log in.';
  @override String get start => 'START';

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
  @override String get organizationManagement => 'Organization Management';

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
  @override String get equipmentDeleted => 'Equipment deleted';
  @override String get equipmentUpdated => 'Equipment updated';
  @override String get equipmentCreated => 'Equipment created';
  @override String get mustBeAValidNumber => 'Must be a valid number';
  @override String get pleaseSelectAnOrganization => 'Please select an organization';

  // Technicians
  @override String get technicians => 'Technicians';
  @override String get addTechnician => 'Add Technician';
  @override String get searchTechnicians => 'Search technicians...';
  @override String get specialty => 'Specialty';
  @override String get availability => 'Availability';
  @override String get allSpecialties => 'All Specialties';
  @override String get registerEditTechnician => 'Register/Edit Technician';
  @override String get technicianDeleted => 'Technician deleted';
  @override String get technicianUpdated => 'Technician updated';
  @override String get technicianCreated => 'Technician created';
  @override String get firstName => 'First Name';
  @override String get secondNameOptional => 'Second Name (Optional)';
  
  // Maintenances
  @override String get maintenances => 'Maintenances';
  @override String get addMaintenance => 'Add Maintenance';
  @override String get searchMaintenances => 'Search maintenances...';
  @override String get scheduleMaintenance => 'Schedule Maintenance';
  @override String get equipment => 'Equipment';
  @override String get technician => 'Technician';
  @override String get maintenanceType => 'Maintenance Type';
  @override String get confirmCompleteMaintenance => 'Are you sure you want to mark this maintenance as completed?';
  @override String get markAsCompleted => 'Mark as Completed';
  @override String get completed => 'Completed';
  @override String get pending => 'Pending';
  @override String get maintenanceDeleted => 'Maintenance deleted';
  @override String get maintenanceUpdated => 'Maintenance updated';
  @override String get maintenanceCreated => 'Maintenance created';
  @override String get maintenanceDetailTitle => 'Maintenance Detail';
  @override String get maintenanceDetailsNotFound => 'Maintenance details not found';
  @override String get maintenanceDetails => 'Maintenance Details';
  @override String get pleaseSelectADate => 'Please select a date';
  @override String get pleaseSelectAnEquipment => 'Please select an equipment';
  @override String get pleaseSelectATechnician => 'Please select a technician';

  // Tasks
  @override String get tasks => 'Tasks';
  @override String get addTask => 'Add Task';
  @override String get searchTasks => 'Search tasks...';
  @override String get taskTemplates => 'Task Templates';
  @override String get taskDescription => 'Task Descripcion';
  @override String get editTaskTemplate => 'Edit Task';
  @override String get addTaskTemplate => 'Add Task';
  @override String get deleteTaskTemplate => 'Delete Task';
  @override String get deleteTaskConfirmation => 'Are you sure you want to delete this task?';
  @override String get registerEditTask => 'Register/Edit Task';
  @override String get responsibleTechnician => 'Responsible Technician';
  @override String get taskState => 'State';
  @override String get taskDate => 'Date';
  @override String get observations => 'Observations';
  @override String get noTasksAssigned => 'No tasks assigned';
  @override String get taskDeleted => 'Task deleted';
  @override String get taskUpdated => 'Task updated';
  @override String get taskCreated => 'Task created';

  // Organizations
  @override String get organization => 'Organization';
  @override String get addOrganization => 'Add Organization';
  @override String get registerEditOrganization => 'Register/Edit Organization';
  @override String get deleteOrganizationConfirmation => 'Are you sure you want to delete this organization?';
  @override String get organizationDeleted => 'Organization deleted';
  @override String get organizationUpdated => 'Organization updated';
  @override String get organizationCreated => 'Organization created';
  @override String get searchByName => 'Search by name...';
  @override String get organizationReport => 'Organization Report';
  @override String get pleaseEnterDescription => 'Please enter a description';

  // Reports
  @override String get generateReport => 'Generate Report';
  @override String get reportPreview => 'Report Preview';
  @override String get datasheetReport => 'Datasheet Report';
  @override String get exportToPDF => 'Export to PDF';
  @override String get maintenanceReport => 'Maintenance Report';
  @override String get dateRange => 'Date Range';
  @override String get selectDateRange => 'Select Date Range';
  @override String get allTechnicians => 'All Technicians';
  @override String get allEquipments => 'All Equipments';
  @override String get startDate => 'Start Date';
  @override String get endDate => 'End Date';
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
  @override String get selectAll => 'Seleccionar Todo';
  @override String get confirmAction => 'Confirmar Acción';
  @override String get confirm => 'Confirmar';
  @override String get edit => 'Editar';
  @override String get retry => 'Reintentar';
  @override String get noResultsFound => 'No se encontraron resultados';
  @override String get notAvailable => 'N/D';
  @override String get unassigned => 'No asignado';
  @override String get statusUpdated => 'Estado actualizado';
  @override String get fieldIsRequired => 'Este campo es requerido';
  @override String get errorLoadingData => 'Error al cargar los datos';
  @override String get unexpectedErrorOccurred => 'Ocurrió un error inesperado';
  @override String get none => 'Ninguna';
  @override String get nameLabel => 'Nombre:';
  @override String get codeLabel => 'Código:';
  @override String get specialtyLabel => 'Especialidad:';
  @override String get scheduledDateLabel => 'Fecha Programada:';
  @override String get statusLabel => 'Estado:';
  @override String get observationsLabel => 'Observaciones:';

  // Parametrized
  @override String confirmDelete(String item) => '¿Estás seguro de que quieres eliminar ${item}?';
  @override String generatePdfForN(int count, String item) => 'Generar PDF para $count ${item}(s)';

  // Login & Registration
  @override String get welcomeBack => 'ENDETECH';
  @override String get signInToContinue => 'Iniciar para continuar en Endetech';
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
  @override String get pleaseEnterName => 'Por favor, introduce tu nombre';
  @override String get confirmPassword => 'Confirmar Contraseña';
  @override String get pleaseConfirmPassword => 'Por favor, confirma tu contraseña';
  @override String get passwordsDoNotMatch => 'Las contraseñas no coinciden';
  @override String get signUp => 'Registrarse';
  @override String get signingUp => 'Registrando...';
  @override String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';
  @override String get continueAsGuest => 'Continuar como Invitado';
  @override String get registrationSuccess => 'Registro exitoso. Por favor, inicie sesión.';
  @override String get start => 'INICIAR';

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
  @override String get organizationManagement => 'Gestión de Organizaciones';

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
  @override String get equipmentDeleted => 'Equipo eliminado';
  @override String get equipmentUpdated => 'Equipo actualizado';
  @override String get equipmentCreated => 'Equipo creado';
  @override String get mustBeAValidNumber => 'Debe ser un número válido';
  @override String get pleaseSelectAnOrganization => 'Por favor, selecciona una organización';

  // Technicians
  @override String get technicians => 'Técnicos';
  @override String get addTechnician => 'Añadir Técnico';
  @override String get searchTechnicians => 'Buscar técnicos...';
  @override String get specialty => 'Especialidad';
  @override String get availability => 'Disponibilidad';
  @override String get allSpecialties => 'Todas las Especialidades';
  @override String get registerEditTechnician => 'Registrar/Editar Técnico';
  @override String get technicianDeleted => 'Técnico eliminado';
  @override String get technicianUpdated => 'Técnico actualizado';
  @override String get technicianCreated => 'Técnico creado';
  @override String get firstName => 'Primer Apellido';
  @override String get secondNameOptional => 'Segundo Apellido (Opcional)';
  
  // Maintenances
  @override String get maintenances => 'Mantenimientos';
  @override String get addMaintenance => 'Añadir Mantenimiento';
  @override String get searchMaintenances => 'Buscar mantenimientos...';
  @override String get scheduleMaintenance => 'Programar Mantenimiento';
  @override String get equipment => 'Equipo';
  @override String get technician => 'Técnico';
  @override String get maintenanceType => 'Tipo de Mantenimiento';
  @override String get confirmCompleteMaintenance => '¿Estás seguro que quieres marcar este mantenimiento como completado?';
  @override String get markAsCompleted => 'Marcar como Completado';
  @override String get completed => 'Completado';
  @override String get pending => 'Pendiente';
  @override String get maintenanceDeleted => 'Mantenimiento eliminado';
  @override String get maintenanceUpdated => 'Mantenimiento actualizado';
  @override String get maintenanceCreated => 'Mantenimiento creado';
  @override String get maintenanceDetailTitle => 'Detalle del Mantenimiento';
  @override String get maintenanceDetailsNotFound => 'No se encontraron detalles del mantenimiento';
  @override String get maintenanceDetails => 'Detalles del Mantenimiento';
  @override String get pleaseSelectADate => 'Por favor, selecciona una fecha';
  @override String get pleaseSelectAnEquipment => 'Por favor, selecciona un equipo';
  @override String get pleaseSelectATechnician => 'Por favor, selecciona un técnico';

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
  @override String get noTasksAssigned => 'No hay tareas asignadas';
  @override String get taskDeleted => 'Tarea eliminada';
  @override String get taskUpdated => 'Tarea actualizada';
  @override String get taskCreated => 'Tarea creada';

  // Organizations
  @override String get organization => 'Organización';
  @override String get addOrganization => 'Añadir Organización';
  @override String get registerEditOrganization => 'Registrar/Editar Organización';
  @override String get deleteOrganizationConfirmation => '¿Estás seguro de que quieres eliminar esta organización?';
  @override String get organizationDeleted => 'Organización eliminada';
  @override String get organizationUpdated => 'Organización actualizada';
  @override String get organizationCreated => 'Organización creada';
  @override String get searchByName => 'Buscar por nombre...';
  @override String get organizationReport => 'Informe de Organizaciones';
  @override String get pleaseEnterDescription => 'Por favor, introduce una descripción';

  // Reports
  @override String get generateReport => 'Generar Informe';
  @override String get reportPreview => 'Vista Previa del Informe';
  @override String get datasheetReport => 'Informe de Ficha Técnica';
  @override String get exportToPDF => 'Exportar a PDF';
  @override String get maintenanceReport => 'Informe de Mantenimiento';
  @override String get dateRange => 'Rango de Fechas';
  @override String get selectDateRange => 'Seleccionar Rango de Fechas';
  @override String get allTechnicians => 'Todos los técnicos';
  @override String get allEquipments => 'Todos los equipos';
  @override String get startDate => 'Fecha de Inicio';
  @override String get endDate => 'Fecha de Fin';
}
