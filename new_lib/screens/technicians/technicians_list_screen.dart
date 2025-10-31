import '../../constants/app_strings.dart';
import '../../models/technician.dart';
import '../../screens/reports/technician_pdf_preview_screen.dart';
import '../../screens/technicians/technician_edit_screen.dart';
import 'package:flutter/material.dart';

class TechniciansListScreen extends StatefulWidget {
  const TechniciansListScreen({super.key});

  @override
  State<TechniciansListScreen> createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  final _searchController = TextEditingController();

  final List<Technician> _allTechnicians = [
    const Technician(name: 'John Doe', specialty: 'Networking', availability: 'Available', status: 'Active'),
    const Technician(name: 'Jane Smith', specialty: 'Hardware', availability: 'On Leave', status: 'Active'),
    const Technician(name: 'Peter Jones', specialty: 'Software', availability: 'Available', status: 'Inactive'),
    const Technician(name: 'Maria Garcia', specialty: 'Servers', availability: 'Available', status: 'Active'),
    const Technician(name: 'David Miller', specialty: 'Networking', availability: 'Busy', status: 'Active'),
  ];

  late List<Technician> _filteredTechnicians;
  final Set<Technician> _selectedTechnicians = {};
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  String? _selectedSpecialty;
  String? _selectedStatus;
  late final List<String> _uniqueSpecialties = _allTechnicians.map((e) => e.specialty).toSet().toList();
  final List<String> _statuses = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _filteredTechnicians = List.from(_allTechnicians);
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
      _filteredTechnicians = _allTechnicians.where((technician) {
        final matchesSearch = query.isEmpty || technician.name.toLowerCase().contains(query);
        final matchesSpecialty = _selectedSpecialty == null || technician.specialty == _selectedSpecialty;
        final matchesStatus = _selectedStatus == null || technician.status == _selectedStatus;
        return matchesSearch && matchesSpecialty && matchesStatus;
      }).toList();
      _selectedTechnicians.removeWhere((item) => !_filteredTechnicians.contains(item));
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 4) return;
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
        case 0: result = a.name.compareTo(b.name); break;
        case 1: result = a.specialty.compareTo(b.specialty); break;
        case 2: result = a.availability.compareTo(b.availability); break;
        case 3: result = a.status.compareTo(b.status); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.technicians)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _searchController, decoration: InputDecoration(hintText: strings.searchTechnicians, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<String>(value: _selectedSpecialty, hint: Text(strings.allSpecialties), onChanged: (val) => setState(() { _selectedSpecialty = val; _applyFilters(); }), items: [DropdownMenuItem(value: null, child: Text(strings.allSpecialties)), ..._uniqueSpecialties.map((s) => DropdownMenuItem(value: s, child: Text(s)))], decoration: InputDecoration(labelText: strings.specialty, border: const OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 16),
                    Expanded(child: DropdownButtonFormField<String>(value: _selectedStatus, hint: Text(strings.allStatuses), onChanged: (val) => setState(() { _selectedStatus = val; _applyFilters(); }), items: [DropdownMenuItem(value: null, child: Text(strings.allStatuses)), ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s)))], decoration: InputDecoration(labelText: strings.status, border: const OutlineInputBorder(), isDense: true))),
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
                  onSelectAll: (selected) => setState(() => selected! ? _selectedTechnicians.addAll(_filteredTechnicians) : _selectedTechnicians.clear()),
                  columns: [
                    DataColumn(label: Text(strings.name), onSort: _onSort),
                    DataColumn(label: Text(strings.specialty), onSort: _onSort),
                    DataColumn(label: Text(strings.availability), onSort: _onSort),
                    DataColumn(label: Text(strings.status), onSort: _onSort),
                    DataColumn(label: Text(strings.actions)),
                  ],
                  rows: _filteredTechnicians.map((technician) {
                    final isSelected = _selectedTechnicians.contains(technician);
                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (selected) => setState(() => isSelected ? _selectedTechnicians.remove(technician) : _selectedTechnicians.add(technician)),
                      cells: [
                        DataCell(Text(technician.name)),
                        DataCell(Text(technician.specialty)),
                        DataCell(Text(technician.availability)),
                        DataCell(Text(technician.status)),
                        DataCell(Row(children: [IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicianEditScreen()))), IconButton(icon: const Icon(Icons.print), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicianPdfPreviewScreen(technicians: [technician]))))])),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedTechnicians.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicianPdfPreviewScreen(technicians: _selectedTechnicians.toList()))),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text('Generate PDF for ${_selectedTechnicians.length} items'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicianEditScreen())), tooltip: strings.addTechnician, child: const Icon(Icons.add)),
    );
  }
}
