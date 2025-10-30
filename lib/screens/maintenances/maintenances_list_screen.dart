import 'package:endetech/constants/app_strings.dart';
import 'package:endetech/screens/maintenances/maintenance_detail_screen.dart';
import 'package:endetech/screens/maintenances/maintenance_programming_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// A simple data class for demonstration purposes
class _Maintenance {
  const _Maintenance({
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

class MaintenancesListScreen extends StatefulWidget {
  const MaintenancesListScreen({super.key});

  @override
  State<MaintenancesListScreen> createState() => _MaintenancesListScreenState();
}

class _MaintenancesListScreenState extends State<MaintenancesListScreen> {
  final _searchController = TextEditingController();

  // Sample data
  final List<_Maintenance> _allMaintenances = [
    _Maintenance(equipment: 'LT-FIN-01', technician: 'John Doe', type: 'Preventive', date: DateTime(2024, 4, 15), status: 'Scheduled'),
    _Maintenance(equipment: 'LT-MKT-02', technician: 'Jane Smith', type: 'Corrective', date: DateTime(2024, 5, 20), status: 'Completed'),
    _Maintenance(equipment: 'PC-DEV-03', technician: 'John Doe', type: 'Preventive', date: DateTime(2024, 3, 1), status: 'In Progress'),
    _Maintenance(equipment: 'SRV-DB-01', technician: 'Maria Garcia', type: 'Preventive', date: DateTime(2024, 6, 5), status: 'Scheduled'),
    _Maintenance(equipment: 'LT-HR-04', technician: 'Jane Smith', type: 'Corrective', date: DateTime(2024, 2, 10), status: 'Completed'),
  ];

  late List<_Maintenance> _filteredMaintenances;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // State for filters
  String? _selectedType;
  String? _selectedStatus;
  late final List<String> _uniqueTypes = _allMaintenances.map((e) => e.type).toSet().toList();
  final List<String> _statuses = ['Scheduled', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _filteredMaintenances = List.from(_allMaintenances);
    _searchController.addListener(_applyFilters);
    _onSort(0, true); // Initial sort
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
            maintenance.equipment.toLowerCase().contains(query) ||
            maintenance.technician.toLowerCase().contains(query);
        
        final matchesType = _selectedType == null || maintenance.type == _selectedType;
        
        final matchesStatus = _selectedStatus == null || maintenance.status == _selectedStatus;

        return matchesSearch && matchesType && matchesStatus;
      }).toList();
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
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
        case 0:
          result = a.equipment.compareTo(b.equipment);
          break;
        case 1:
          result = a.technician.compareTo(b.technician);
          break;
        case 2:
          result = a.type.compareTo(b.type);
          break;
        case 3:
          result = a.date.compareTo(b.date);
          break;
        case 4:
          result = a.status.compareTo(b.status);
          break;
      }
      return _sortAscending ? result : -result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.maintenances),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchMaintenances,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        hint: const Text(AppStrings.allTypes),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType = newValue;
                            _applyFilters();
                          });
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(AppStrings.allTypes),
                          ),
                          ..._uniqueTypes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ],
                        decoration: const InputDecoration(
                          labelText: AppStrings.type,
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        hint: const Text(AppStrings.allStatuses),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                            _applyFilters();
                          });
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(AppStrings.allStatuses),
                          ),
                          ..._statuses.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ],
                        decoration: const InputDecoration(
                          labelText: AppStrings.status,
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(label: const Text(AppStrings.equipment), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.technician), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.maintenanceType), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.date), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.status), onSort: _onSort),
                  const DataColumn(label: Text(AppStrings.actions)),
                ],
                rows: _filteredMaintenances.map((maintenance) {
                  return DataRow(
                    cells: [
                      DataCell(Text(maintenance.equipment)),
                      DataCell(Text(maintenance.technician)),
                      DataCell(Text(maintenance.type)),
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(maintenance.date))),
                      DataCell(Text(maintenance.status)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MaintenanceDetailScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MaintenanceProgrammingScreen()),
          );
        },
        tooltip: AppStrings.addMaintenance,
        child: const Icon(Icons.add),
      ),
    );
  }
}
