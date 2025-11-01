import '../../constants/app_strings.dart';
import '../../models/maintenance.dart';
import './maintenance_detail_screen.dart';
import './maintenance_programming_screen.dart';
import '../reports/maintenance_pdf_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenancesListScreen extends StatefulWidget {
  const MaintenancesListScreen({super.key});

  @override
  State<MaintenancesListScreen> createState() => _MaintenancesListScreenState();
}

class _MaintenancesListScreenState extends State<MaintenancesListScreen> {
  final _searchController = TextEditingController();

  final List<Maintenance> _allMaintenances = [
    Maintenance(equipment: 'LT-FIN-01', technician: 'John Doe', type: 'Preventive', date: DateTime(2024, 4, 15), status: 'Scheduled'),
    Maintenance(equipment: 'LT-MKT-02', technician: 'Jane Smith', type: 'Corrective', date: DateTime(2024, 5, 20), status: 'Completed'),
    Maintenance(equipment: 'PC-DEV-03', technician: 'John Doe', type: 'Preventive', date: DateTime(2024, 3, 1), status: 'In Progress'),
    Maintenance(equipment: 'SRV-DB-01', technician: 'Maria Garcia', type: 'Preventive', date: DateTime(2024, 6, 5), status: 'Scheduled'),
    Maintenance(equipment: 'LT-HR-04', technician: 'Jane Smith', type: 'Corrective', date: DateTime(2024, 2, 10), status: 'Completed'),
  ];

  late List<Maintenance> _filteredMaintenances;
  final Set<Maintenance> _selectedMaintenances = {};
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  String? _selectedType;
  String? _selectedStatus;
  late final List<String> _uniqueTypes = _allMaintenances.map((e) => e.type).toSet().toList();
  final List<String> _statuses = ['Scheduled', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _filteredMaintenances = List.from(_allMaintenances);
    _searchController.addListener(_applyFilters);
    _onSort(_sortColumnIndex, _sortAscending);
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
      _selectedMaintenances.removeWhere((item) => !_filteredMaintenances.contains(item));
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 5) return;
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
        case 0: result = a.equipment.compareTo(b.equipment); break;
        case 1: result = a.technician.compareTo(b.technician); break;
        case 2: result = a.type.compareTo(b.type); break;
        case 3: result = a.date.compareTo(b.date); break;
        case 4: result = a.status.compareTo(b.status); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.maintenances)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _searchController, decoration: InputDecoration(hintText: strings.searchMaintenances, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(labelText: strings.type, border: const OutlineInputBorder(), isDense: true),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedType,
                                hint: Text(strings.allTypes),
                                isDense: true,
                                onChanged: (val) => setState(() { _selectedType = val; _applyFilters(); }),
                                items: [
                                  DropdownMenuItem(value: null, child: Text(strings.allTypes)),
                                  ..._uniqueTypes.map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FormField<String>(
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
                                  ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                ],
                              ),
                            ),
                          );
                        },
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
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSelectAll: (selected) => setState(() => selected! ? _selectedMaintenances.addAll(_filteredMaintenances) : _selectedMaintenances.clear()),
                  columns: [
                    DataColumn(label: Text(strings.equipment), onSort: _onSort),
                    DataColumn(label: Text(strings.technician), onSort: _onSort),
                    DataColumn(label: Text(strings.maintenanceType), onSort: _onSort),
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
                        DataCell(Text(maintenance.equipment)),
                        DataCell(Text(maintenance.technician)),
                        DataCell(Text(maintenance.type)),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(maintenance.date))),
                        DataCell(Text(maintenance.status)),
                        DataCell(Row(children: [IconButton(icon: const Icon(Icons.visibility), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceDetailScreen()))), IconButton(icon: const Icon(Icons.print), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaintenancePdfPreviewScreen(maintenances: [maintenance]))))])),
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
