import 'dart:convert';
import 'package:endetech/api/api_service.dart';
import 'package:endetech/models/maintenance.dart';
import 'package:endetech/screens/maintenances/maintenance_detail_screen.dart';
import 'package:endetech/screens/maintenances/maintenance_programming_screen.dart';
import 'package:endetech/screens/reports/maintenance_pdf_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../constants/app_strings.dart';

class MaintenancesListScreen extends StatefulWidget {
  const MaintenancesListScreen({super.key});

  @override
  State<MaintenancesListScreen> createState() => _MaintenancesListScreenState();
}

class _MaintenancesListScreenState extends State<MaintenancesListScreen> {
  final _searchController = TextEditingController();

  List<Maintenance> _allMaintenances = [];
  late List<Maintenance> _filteredMaintenances;
  bool _isLoading = true;

  final Set<Maintenance> _selectedMaintenances = {};
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  String? _selectedStatus;
  final List<String> _statuses = ['programado', 'en progreso', 'completado'];

  @override
  void initState() {
    super.initState();
    _filteredMaintenances = [];
    _fetchMaintenances();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _fetchMaintenances() async {
    try {
      final response = await http.get(Uri.parse(ApiService.mantenimientos));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('mantenimientos') && body['mantenimientos'] != null) {
          final List<dynamic> data = body['mantenimientos'];
          setState(() {
            _allMaintenances = data.map((json) => Maintenance.fromJson(json)).toList();
            _filteredMaintenances = List.from(_allMaintenances);
            _onSort(_sortColumnIndex, _sortAscending); 
          });
        }
      } else {
        throw Exception('Failed to load maintenances');
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMaintenances = _allMaintenances.where((maintenance) {
        final matchesSearch = query.isEmpty ||
            maintenance.equipo.codigo.toLowerCase().contains(query) ||
            maintenance.tecnico.fullName.toLowerCase().contains(query);
        final matchesStatus = _selectedStatus == null || maintenance.estado == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
      _selectedMaintenances.removeWhere((item) => !_filteredMaintenances.contains(item));
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 4) return; // Action column is not sortable
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortFilteredList();
    });
  }

  void _sortFilteredList() {
    _filteredMaintenances.sort((a, b) {
      int result = 0;
      switch (_sortColumnIndex) {
        case 0: result = a.equipo.codigo.compareTo(b.equipo.codigo); break;
        case 1: result = a.tecnico.fullName.compareTo(b.tecnico.fullName); break;
        case 2: result = a.fechaProgramada.compareTo(b.fechaProgramada); break;
        case 3: result = a.estado.compareTo(b.estado); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  void _deleteMaintenance(Maintenance maintenance) {
    setState(() {
      _allMaintenances.remove(maintenance);
      _applyFilters();
    });
  }

  void _editMaintenance(Maintenance maintenance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceProgrammingScreen(maintenanceToEdit: maintenance),
      ),
    );
  }

  void _changeMaintenanceStatus(Maintenance maintenance, String newStatus) {
    setState(() {
      final index = _allMaintenances.indexWhere((m) => m.id == maintenance.id);
      if (index != -1) {
        _allMaintenances[index] = maintenance.copyWith(estado: newStatus);
        _applyFilters();
      }
    });
  }

  void _confirmChangeStatus(Maintenance maintenance, String newStatus) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.confirmAction),
          content: Text(strings.confirmCompleteMaintenance),
          actions: <Widget>[
            TextButton(
              child: Text(strings.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(strings.confirm),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _changeMaintenanceStatus(maintenance, newStatus);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.maintenances)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(controller: _searchController, decoration: InputDecoration(hintText: strings.searchMaintenances, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), isDense: true)),
                      const SizedBox(height: 12),
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(labelText: strings.status, border: const OutlineInputBorder(), isDense: true),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                hint: Text(strings.allStatuses),
                                isDense: true,
                                onChanged: (val) => setState(() { _selectedStatus = val; _applyFilters(); }),
                                items: [
                                  DropdownMenuItem(value: null, child: Text(strings.allStatuses)),
                                  ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.characters.first.toUpperCase() + s.substring(1))))
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        onSelectAll: (selected) => setState(() => selected! ? _selectedMaintenances.addAll(_filteredMaintenances) : _selectedMaintenances.clear()),
                        columns: [
                          DataColumn(label: Text(strings.equipment), onSort: _onSort),
                          DataColumn(label: Text(strings.technician), onSort: _onSort),
                          DataColumn(label: Text(strings.date), onSort: _onSort),
                          DataColumn(label: Text(strings.status), onSort: _onSort),
                          DataColumn(label: Text(strings.actions)),
                        ],
                        rows: _filteredMaintenances.map((maintenance) {
                          final isSelected = _selectedMaintenances.contains(maintenance);
                          return DataRow(
                            selected: isSelected,
                            onSelectChanged: (selected) => setState(() => isSelected ? _selectedMaintenances.remove(maintenance) : _selectedMaintenances.add(maintenance)),
                            cells: [
                              DataCell(Text(maintenance.equipo.codigo)),
                              DataCell(Text(maintenance.tecnico.fullName)),
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(maintenance.fechaProgramada))),
                              DataCell(Text(maintenance.estado)),
                              DataCell(Row(children: [
                                IconButton(icon: const Icon(Icons.visibility), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceDetailScreen()))),
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _editMaintenance(maintenance)),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteMaintenance(maintenance)),
                                IconButton(icon: const Icon(Icons.print), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaintenancePdfPreviewScreen(maintenances: [maintenance])))),
                                if (maintenance.estado == 'programado' || maintenance.estado == 'completado')
                                  IconButton(
                                    icon: Icon(Icons.check_circle, color: maintenance.estado == 'programado' ? Colors.green : Colors.grey),
                                    tooltip: maintenance.estado == 'programado' ? strings.markAsCompleted : strings.completed,
                                    onPressed: maintenance.estado == 'programado'
                                        ? () => _confirmChangeStatus(maintenance, 'completado')
                                        : null,
                                  ),
                              ])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _selectedMaintenances.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaintenancePdfPreviewScreen(maintenances: _selectedMaintenances.toList()))),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text('Generate PDF for ${_selectedMaintenances.length} items'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceProgrammingScreen())), tooltip: strings.addMaintenance, child: const Icon(Icons.add)),
    );
  }
}
