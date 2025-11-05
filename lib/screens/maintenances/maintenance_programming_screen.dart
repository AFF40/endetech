import 'package:endetech/models/equipment.dart';
import 'package:endetech/models/maintenance.dart';
import 'package:endetech/models/technician.dart';
import 'package:intl/intl.dart';
import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/task.dart';
import 'package:flutter/material.dart';

class MaintenanceProgrammingScreen extends StatefulWidget {
  final Maintenance? maintenanceToEdit;

  const MaintenanceProgrammingScreen({super.key, this.maintenanceToEdit});

  @override
  State<MaintenanceProgrammingScreen> createState() =>
      _MaintenanceProgrammingScreenState();
}

class _MaintenanceProgrammingScreenState
    extends State<MaintenanceProgrammingScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _selectedDate;
  final _observationsController = TextEditingController();

  List<Task> _allTasks = [];
  final Set<Task> _selectedTasks = {};
  bool _areAllTasksSelected = false;

  List<Equipment> _equipments = [];
  Equipment? _selectedEquipment;

  List<Technician> _technicians = [];
  Technician? _selectedTechnician;

  bool _isLoading = true;
  String _errorMessage = '';
  bool _isSaving = false;

  // Represents the status: true for 'pendiente', false for 'completado'
  bool _isPending = true; 

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        _apiService.getTareas(),
        _apiService.getEquipos(),
        _apiService.getTecnicos(),
      ]);

      if (!mounted) return;

      final tasksResult = results[0];
      final equipmentsResult = results[1];
      final techniciansResult = results[2];

      if (!tasksResult['success'] || !equipmentsResult['success'] || !techniciansResult['success']) {
        final strings = AppStrings.of(context);
        setState(() {
          _errorMessage = tasksResult['message'] ?? equipmentsResult['message'] ?? techniciansResult['message'] ?? strings.errorLoadingData;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _allTasks = (tasksResult['data']['tareas'] as List).map((t) => Task.fromJson(t)).toList();
        _equipments = (equipmentsResult['data']['equipos'] as List).map((e) => Equipment.fromJson(e)).toList();
        _technicians = (techniciansResult['data']['tecnicos'] as List).map((t) => Technician.fromJson(t)).toList();

        if (widget.maintenanceToEdit != null) {
          _loadMaintenanceData(widget.maintenanceToEdit!);
        } else {
          _selectedDate = DateTime.now();
        }
        
        _isLoading = false;
      });

    } catch (e) {
      if(mounted){
        final strings = AppStrings.of(context);
        setState(() {
          _errorMessage = strings.unexpectedErrorOccurred;
          _isLoading = false;
        });
      }
    }
  }

  void _loadMaintenanceData(Maintenance maintenance) {
    _selectedDate = maintenance.fechaProgramada;
    _observationsController.text = maintenance.observaciones ?? '';
    _isPending = maintenance.estado == 'pendiente';

    try {
      _selectedEquipment = _equipments.firstWhere((e) => e.id == maintenance.equipo?.id);
    } on StateError {
      _selectedEquipment = null;
    }

    try {
      _selectedTechnician = _technicians.firstWhere((t) => t.id == maintenance.tecnico?.id);
    } on StateError {
      _selectedTechnician = null;
    }

    final taskIds = maintenance.tareas.map((t) => t.id).toSet();
    _selectedTasks.addAll(_allTasks.where((task) => taskIds.contains(task.id)));

    if (_allTasks.isNotEmpty && _selectedTasks.length == _allTasks.length) {
      _areAllTasksSelected = true;
    }
  }

  void _toggleSelectAllTasks(bool selected) {
    setState(() {
      if (selected) {
        _selectedTasks.addAll(_allTasks);
      } else {
        _selectedTasks.clear();
      }
      _areAllTasksSelected = selected;
    });
  }

  Future<void> _saveMaintenance() async {
    if (!_formKey.currentState!.validate()) return;

    final strings = AppStrings.of(context);
    setState(() {
      _isSaving = true;
    });

    final data = {
      'fecha_programada': DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!),
      'equipo_id': _selectedEquipment!.id,
      'tecnico_id': _selectedTechnician!.id,
      'observaciones': _observationsController.text,
      'tareas': _selectedTasks.map((task) => task.id).toList(),
      'estado': _isPending ? 'pendiente' : 'completado',
    };

    final isEditing = widget.maintenanceToEdit != null;
    final result = isEditing
        ? await _apiService.updateMantenimiento(widget.maintenanceToEdit!.id, data)
        : await _apiService.createMantenimiento(data);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      final message = result['success'] 
          ? (result['data']?['message'] ?? (isEditing ? strings.maintenanceUpdated : strings.maintenanceCreated))
          : result['message'] ?? strings.unexpectedErrorOccurred;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

      if (result['success']) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Widget _buildErrorView() {
    final strings = AppStrings.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _initializeScreen, child: Text(strings.retry)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isEditing = widget.maintenanceToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? strings.registerEditTask : strings.scheduleMaintenance),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
            ? _buildErrorView()
            : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FormField<DateTime>(
                                initialValue: _selectedDate,
                                builder: (FormFieldState<DateTime> state) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(strings.date, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: state.hasError ? Theme.of(context).colorScheme.error : Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Transform.scale(
                                          scale: 0.9,
                                          child: CalendarDatePicker(
                                            initialDate: _selectedDate,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            onDateChanged: (newDate) {
                                              state.didChange(newDate);
                                              setState(() => _selectedDate = newDate);
                                            },
                                          ),
                                        ),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                                          child: Text(state.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                                        )
                                    ],
                                  );
                                },
                                validator: (value) => value == null ? strings.pleaseSelectADate : null,
                              ),
                              const SizedBox(height: 16),
                              Autocomplete<Equipment>(
                                initialValue: TextEditingValue(text: _selectedEquipment?.nombre ?? ''),
                                displayStringForOption: (option) => '${option.nombre} (${option.codigo})',
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) return _equipments;
                                  return _equipments.where((e) => e.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()) || e.codigo.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                },
                                onSelected: (Equipment selection) => setState(() => _selectedEquipment = selection),
                                fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
                                  return TextFormField(
                                    controller: fieldController,
                                    focusNode: fieldFocusNode,
                                    decoration: InputDecoration(labelText: strings.equipment, border: const OutlineInputBorder()),
                                    validator: (value) => _selectedEquipment == null ? strings.pleaseSelectAnEquipment : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Autocomplete<Technician>(
                                initialValue: TextEditingValue(text: _selectedTechnician?.fullName ?? ''),
                                displayStringForOption: (option) => option.fullName,
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) return _technicians;
                                  return _technicians.where((t) => t.fullName.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                                },
                                onSelected: (Technician selection) => setState(() => _selectedTechnician = selection),
                                fieldViewBuilder: (context, fieldController, fieldFocusNode, onFieldSubmitted) {
                                  return TextFormField(
                                    controller: fieldController,
                                    focusNode: fieldFocusNode,
                                    decoration: InputDecoration(labelText: strings.technician, border: const OutlineInputBorder()),
                                    validator: (value) => _selectedTechnician == null ? strings.pleaseSelectATechnician : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              if(_allTasks.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(strings.tasks, style: Theme.of(context).textTheme.titleMedium),
                                        ActionChip(
                                          avatar: Icon(_areAllTasksSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 18),
                                          label: Text(strings.selectAll),
                                          onPressed: () => _toggleSelectAllTasks(!_areAllTasksSelected),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.all(12.0),
                                      child: Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: _allTasks.map((task) {
                                          final isSelected = _selectedTasks.any((t) => t.id == task.id);
                                          return FilterChip(
                                            label: Text(task.nombre),
                                            selected: isSelected,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                if (selected) { _selectedTasks.add(task); } else { _selectedTasks.removeWhere((t) => t.id == task.id); }
                                                _areAllTasksSelected = _allTasks.isNotEmpty && _selectedTasks.length == _allTasks.length;
                                              });
                                            },
                                            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                            checkmarkColor: Theme.of(context).primaryColor,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _observationsController,
                                decoration: InputDecoration(labelText: strings.observations, border: const OutlineInputBorder()),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              if (isEditing)
                                SwitchListTile(
                                  title: Text(strings.status),
                                  subtitle: Text(_isPending ? strings.pending : strings.completed),
                                  value: _isPending,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _isPending = value;
                                    });
                                  },
                                  secondary: Icon(_isPending ? Icons.pending_actions : Icons.check_circle, color: _isPending ? Colors.orange : Colors.green),
                                ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _isSaving ? null : _saveMaintenance,
                                child: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(strings.save, style: const TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
