import 'dart:convert';
import 'package:endetech/models/equipment.dart';
import 'package:endetech/models/maintenance.dart';
import 'package:endetech/models/technician.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../api/api_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final _observationsController = TextEditingController();

  final List<Task> _allTasks = [];
  final Set<Task> _selectedTasks = {};
  bool _areAllTasksSelected = false;

  List<Equipment> _equipments = [];
  Equipment? _selectedEquipment;

  List<Technician> _technicians = [];
  Technician? _selectedTechnician;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await Future.wait([
      _fetchTasks(),
      _fetchEquipments(),
      _fetchTechnicians(),
    ]);

    if (widget.maintenanceToEdit != null) {
      _loadMaintenanceData(widget.maintenanceToEdit!);
    } else {
      _selectedDate = DateTime.now();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _loadMaintenanceData(Maintenance maintenance) {
    _selectedDate = maintenance.fechaProgramada;
    _selectedEquipment = maintenance.equipo;
    _selectedTechnician = maintenance.tecnico;
    _observationsController.text = maintenance.observaciones ?? '';

    final taskIds = maintenance.tareas.map((t) => t.id).toSet();
    _selectedTasks
        .addAll(_allTasks.where((task) => taskIds.contains(task.id)));

    if (_allTasks.isNotEmpty && _selectedTasks.length == _allTasks.length) {
      _areAllTasksSelected = true;
    }
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(ApiService.tareas));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('tareas') && body['tareas'] != null) {
          final List<dynamic> data = body['tareas'];
          final tasks = data.map((json) => Task.fromJson(json)).toList();
          tasks.sort((a, b) => a.nombre.compareTo(b.nombre));
          setState(() {
            _allTasks.addAll(tasks);
          });
        }
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchEquipments() async {
    try {
      final response = await http.get(Uri.parse(ApiService.equipos));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('equipos') && body['equipos'] != null) {
          final List<dynamic> data = body['equipos'];
          setState(() {
            _equipments =
                data.map((json) => Equipment.fromJson(json)).toList();
          });
        }
      } else {
        throw Exception('Failed to load equipments');
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchTechnicians() async {
    try {
      final response = await http.get(Uri.parse(ApiService.tecnicos));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('tecnicos') && body['tecnicos'] != null) {
          final List<dynamic> data = body['tecnicos'];
          setState(() {
            _technicians =
                data.map((json) => Technician.fromJson(json)).toList();
          });
        }
      } else {
        throw Exception('Failed to load technicians');
      }
    } catch (e) {
      // Handle error
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

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isEditing = widget.maintenanceToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing ? strings.registerEditTask : strings.scheduleMaintenance),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                                builder: (FormFieldState<DateTime> state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(strings.date,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: state.hasError
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .error
                                                  : Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Transform.scale(
                                          scale: 0.9,
                                          child: CalendarDatePicker(
                                            initialDate: _selectedDate,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            onDateChanged: (newDate) {
                                              state.didChange(newDate);
                                              setState(() {
                                                _selectedDate = newDate;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      if (state.hasError)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0, left: 12.0),
                                          child: Text(state.errorText!,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                  fontSize: 12)),
                                        )
                                    ],
                                  );
                                },
                                validator: (value) {
                                  if (_selectedDate == null) {
                                    return 'Please select a date';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Autocomplete<Equipment>(
                                initialValue: TextEditingValue(
                                    text: _selectedEquipment?.codigo ?? ''),
                                displayStringForOption: (option) =>
                                    option.codigo,
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return _equipments;
                                  }
                                  return _equipments.where((equipment) {
                                    return equipment.codigo
                                            .toLowerCase()
                                            .contains(textEditingValue.text
                                                .toLowerCase()) ||
                                        equipment.nombre
                                            .toLowerCase()
                                            .contains(textEditingValue.text
                                                .toLowerCase());
                                  });
                                },
                                onSelected: (Equipment selection) {
                                  setState(() {
                                    _selectedEquipment = selection;
                                  });
                                },
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController fieldController,
                                    FocusNode fieldFocusNode,
                                    VoidCallback onFieldSubmitted) {
                                  return TextFormField(
                                    controller: fieldController,
                                    focusNode: fieldFocusNode,
                                    decoration: InputDecoration(
                                      labelText: strings.equipment,
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (_selectedEquipment == null) {
                                        return 'Please select an equipment';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Autocomplete<Technician>(
                                initialValue: TextEditingValue(
                                    text: _selectedTechnician?.fullName ?? ''),
                                displayStringForOption: (option) =>
                                    option.fullName,
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return _technicians;
                                  }
                                  return _technicians.where((technician) {
                                    return technician.fullName
                                        .toLowerCase()
                                        .contains(textEditingValue.text
                                            .toLowerCase());
                                  });
                                },
                                onSelected: (Technician selection) {
                                  setState(() {
                                    _selectedTechnician = selection;
                                  });
                                },
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController fieldController,
                                    FocusNode fieldFocusNode,
                                    VoidCallback onFieldSubmitted) {
                                  return TextFormField(
                                    controller: fieldController,
                                    focusNode: fieldFocusNode,
                                    decoration: InputDecoration(
                                      labelText: strings.technician,
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (_selectedTechnician == null) {
                                        return 'Please select a technician';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(strings.tasks,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      ActionChip(
                                        avatar: Icon(
                                            _areAllTasksSelected
                                                ? Icons.check_box
                                                : Icons
                                                    .check_box_outline_blank,
                                            size: 18),
                                        label: Text(strings.selectAll),
                                        onPressed: () =>
                                            _toggleSelectAllTasks(
                                                !_areAllTasksSelected),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(12.0),
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: _allTasks.map((task) {
                                        final isSelected = _selectedTasks
                                            .any((t) => t.id == task.id);
                                        return FilterChip(
                                          label: Text(task.nombre),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              if (selected) {
                                                _selectedTasks.add(task);
                                              } else {
                                                _selectedTasks.removeWhere(
                                                    (t) => t.id == task.id);
                                              }
                                              _areAllTasksSelected = _allTasks
                                                      .isNotEmpty &&
                                                  _selectedTasks.length ==
                                                      _allTasks.length;
                                            });
                                          },
                                          selectedColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.2),
                                          checkmarkColor:
                                              Theme.of(context).primaryColor,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _observationsController,
                                decoration: InputDecoration(
                                  labelText: strings.observations,
                                  border: const OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // TODO: Implement save logic with _selectedTasks and _selectedDate
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Saving Maintenance...')),
                                    );
                                  }
                                },
                                child: Text(
                                  strings.save,
                                  style: const TextStyle(fontSize: 16),
                                ),
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
