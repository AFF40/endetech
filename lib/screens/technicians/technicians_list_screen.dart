import 'package:endetech/constants/app_strings.dart';
import 'package:endetech/screens/technicians/technician_edit_screen.dart';
import 'package:flutter/material.dart';

// A simple data class for demonstration purposes
class _Technician {
  const _Technician({
    required this.name,
    required this.specialty,
    required this.availability,
    required this.status,
  });
  final String name;
  final String specialty;
  final String availability;
  final String status;
}

class TechniciansListScreen extends StatefulWidget {
  const TechniciansListScreen({super.key});

  @override
  State<TechniciansListScreen> createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  final _searchController = TextEditingController();

  // Sample data
  final List<_Technician> _allTechnicians = [
    const _Technician(name: 'John Doe', specialty: 'Networking', availability: 'Available', status: 'Active'),
    const _Technician(name: 'Jane Smith', specialty: 'Hardware', availability: 'On Leave', status: 'Active'),
    const _Technician(name: 'Peter Jones', specialty: 'Software', availability: 'Available', status: 'Inactive'),
    const _Technician(name: 'Maria Garcia', specialty: 'Servers', availability: 'Available', status: 'Active'),
    const _Technician(name: 'David Miller', specialty: 'Networking', availability: 'Busy', status: 'Active'),
  ];

  late List<_Technician> _filteredTechnicians;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // State for filters
  String? _selectedSpecialty;
  String? _selectedStatus;
  late final List<String> _uniqueSpecialties = _allTechnicians.map((e) => e.specialty).toSet().toList();
  final List<String> _statuses = ['Active', 'Inactive'];

  bool _isNavigating = false; // Flag to prevent double navigation

  @override
  void initState() {
    super.initState();
    _filteredTechnicians = List.from(_allTechnicians);
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
      _filteredTechnicians = _allTechnicians.where((technician) {
        final matchesSearch = query.isEmpty || technician.name.toLowerCase().contains(query);
        final matchesSpecialty = _selectedSpecialty == null || technician.specialty == _selectedSpecialty;
        final matchesStatus = _selectedStatus == null || technician.status == _selectedStatus;

        return matchesSearch && matchesSpecialty && matchesStatus;
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
    _filteredTechnicians.sort((a, b) {
      int result = 0;
      switch (_sortColumnIndex) {
        case 0:
          result = a.name.compareTo(b.name);
          break;
        case 1:
          result = a.specialty.compareTo(b.specialty);
          break;
        case 2:
          result = a.availability.compareTo(b.availability);
          break;
        case 3:
          result = a.status.compareTo(b.status);
          break;
      }
      return _sortAscending ? result : -result;
    });
  }

  void _navigateToEditScreen() {
    if (_isNavigating) return; // Prevent action if already navigating
    setState(() => _isNavigating = true);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TechnicianEditScreen()),
    ).then((_) {
      // Reset flag when navigation is complete (screen is popped)
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.technicians),
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
                    hintText: AppStrings.searchTechnicians,
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
                        value: _selectedSpecialty,
                        hint: const Text(AppStrings.allSpecialties),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSpecialty = newValue;
                            _applyFilters();
                          });
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(AppStrings.allSpecialties),
                          ),
                          ..._uniqueSpecialties.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ],
                        decoration: const InputDecoration(
                          labelText: AppStrings.specialty,
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
                  DataColumn(label: const Text(AppStrings.name), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.specialty), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.availability), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.status), onSort: _onSort),
                  const DataColumn(label: Text(AppStrings.actions)),
                ],
                rows: _filteredTechnicians.map((technician) {
                  return DataRow(
                    cells: [
                      DataCell(Text(technician.name)),
                      DataCell(Text(technician.specialty)),
                      DataCell(Text(technician.availability)),
                      DataCell(Text(technician.status)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _navigateToEditScreen,
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
        onPressed: _navigateToEditScreen,
        tooltip: AppStrings.addTechnician,
        child: const Icon(Icons.add),
      ),
    );
  }
}
