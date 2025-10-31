import '../../constants/app_strings.dart';
import '../../models/equipment.dart';
import '../../screens/equipments/equipment_edit_screen.dart';
import '../../screens/reports/pdf_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EquipmentsListScreen extends StatefulWidget {
  const EquipmentsListScreen({super.key});

  @override
  State<EquipmentsListScreen> createState() => _EquipmentsListScreenState();
}

class _EquipmentsListScreenState extends State<EquipmentsListScreen> {
  final _searchController = TextEditingController();

  final List<Equipment> _allEquipments = [
    Equipment(assetCode: 'EQ-001', name: 'Laptop Financiero 01', type: 'Laptop', brand: 'HP', organizationId: 'FIN-01', status: 'Active', lastMaintenance: DateTime(2023, 10, 15), nextMaintenance: DateTime(2024, 4, 15), characteristics: 'Intel i5, 8GB RAM, 256GB SSD'),
    Equipment(assetCode: 'EQ-002', name: 'Laptop Marketing 02', type: 'Laptop', brand: 'Dell', organizationId: 'MKT-02', status: 'Active', lastMaintenance: DateTime(2023, 11, 20), nextMaintenance: DateTime(2024, 5, 20), characteristics: 'Intel i7, 16GB RAM, 512GB SSD'),
    Equipment(assetCode: 'EQ-003', name: 'PC Desarrollo 03', type: 'Desktop', brand: 'Lenovo', organizationId: 'DEV-03', status: 'In Repair', lastMaintenance: DateTime(2023, 9, 1), nextMaintenance: DateTime(2024, 3, 1), characteristics: 'AMD Ryzen 5, 16GB RAM, 1TB HDD'),
    Equipment(assetCode: 'EQ-004', name: 'Servidor Base de Datos', type: 'Server', brand: 'Dell', organizationId: 'SRV-01', status: 'Active', lastMaintenance: DateTime(2023, 12, 5), nextMaintenance: DateTime(2024, 6, 5), characteristics: 'Xeon E-2224, 32GB RAM, 2TB RAID'),
    Equipment(assetCode: 'EQ-005', name: 'Laptop RRHH 04', type: 'Laptop', brand: 'HP', organizationId: 'HR-04', status: 'Inactive', lastMaintenance: DateTime(2023, 8, 10), nextMaintenance: DateTime(2024, 2, 10), characteristics: 'Intel i5, 8GB RAM, 256GB SSD'),
    Equipment(assetCode: 'EQ-006', name: 'PC Diseño 05', type: 'Desktop', brand: 'Apple', organizationId: 'DSN-05', status: 'Active', lastMaintenance: DateTime(2023, 10, 25), nextMaintenance: DateTime(2024, 4, 25), characteristics: 'Apple M1, 16GB RAM, 512GB SSD'),
  ];

  late List<Equipment> _filteredEquipments;
  final Set<Equipment> _selectedEquipments = {};
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  String? _selectedBrand;
  String? _selectedStatus;
  String? _selectedType;
  late final List<String> _uniqueBrands = _allEquipments.map((e) => e.brand).toSet().toList();
  late final List<String> _uniqueTypes = _allEquipments.map((e) => e.type).toSet().toList();
  final List<String> _statuses = ['Active', 'Inactive', 'In Repair'];

  @override
  void initState() {
    super.initState();
    _filteredEquipments = List.from(_allEquipments);
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
      _filteredEquipments = _allEquipments.where((equipment) {
        final matchesSearch = query.isEmpty ||
            equipment.name.toLowerCase().contains(query) ||
            equipment.assetCode.toLowerCase().contains(query);
        final matchesBrand = _selectedBrand == null || equipment.brand == _selectedBrand;
        final matchesStatus = _selectedStatus == null || equipment.status == _selectedStatus;
        final matchesType = _selectedType == null || equipment.type == _selectedType;
        return matchesSearch && matchesBrand && matchesStatus && matchesType;
      }).toList();
      _selectedEquipments.removeWhere((item) => !_filteredEquipments.contains(item));
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 8) return;
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortFilteredList();
    });
  }

  void _sortFilteredList() {
    _filteredEquipments.sort((a, b) {
      int result = 0;
      switch (_sortColumnIndex) {
        case 0: result = a.assetCode.compareTo(b.assetCode); break;
        case 1: result = a.name.compareTo(b.name); break;
        case 2: result = a.type.compareTo(b.type); break;
        case 3: result = a.brand.compareTo(b.brand); break;
        case 4: result = a.organizationId.compareTo(b.organizationId); break;
        case 5: result = a.status.compareTo(b.status); break;
        case 6: result = a.lastMaintenance.compareTo(b.lastMaintenance); break;
        case 7: result = a.nextMaintenance.compareTo(b.nextMaintenance); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  void _showDeleteConfirmation(Equipment equipment) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text('Are you sure you want to delete ${equipment.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
            TextButton(
              onPressed: () {
                setState(() {
                  _allEquipments.remove(equipment);
                  _applyFilters();
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(strings.delete),
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
      appBar: AppBar(title: Text(strings.equipments)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _searchController, decoration: InputDecoration(hintText: strings.searchEquipments, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<String>(value: _selectedBrand, hint: Text(strings.allBrands), onChanged: (val) => setState(() { _selectedBrand = val; _applyFilters(); }), items: [DropdownMenuItem(value: null, child: Text(strings.allBrands)), ..._uniqueBrands.map((b) => DropdownMenuItem(value: b, child: Text(b)))], decoration: InputDecoration(labelText: strings.brand, border: const OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 16),
                    Expanded(child: DropdownButtonFormField<String>(value: _selectedStatus, hint: Text(strings.allStatuses), onChanged: (val) => setState(() { _selectedStatus = val; _applyFilters(); }), items: [DropdownMenuItem(value: null, child: Text(strings.allStatuses)), ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s)))], decoration: InputDecoration(labelText: strings.status, border: const OutlineInputBorder(), isDense: true))),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: _selectedType, hint: Text(strings.allTypes), onChanged: (val) => setState(() { _selectedType = val; _applyFilters(); }), items: [DropdownMenuItem(value: null, child: Text(strings.allTypes)), ..._uniqueTypes.map((t) => DropdownMenuItem(value: t, child: Text(t)))], decoration: InputDecoration(labelText: strings.type, border: const OutlineInputBorder(), isDense: true)),
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
                  onSelectAll: (selected) => setState(() => selected! ? _selectedEquipments.addAll(_filteredEquipments) : _selectedEquipments.clear()),
                  columns: [
                    DataColumn(label: Text(strings.assetCode), onSort: _onSort),
                    DataColumn(label: Text(strings.equipmentName), onSort: _onSort),
                    DataColumn(label: Text(strings.type), onSort: _onSort),
                    DataColumn(label: Text(strings.brand), onSort: _onSort),
                    DataColumn(label: Text(strings.organizationId), onSort: _onSort),
                    DataColumn(label: Text(strings.status), onSort: _onSort),
                    DataColumn(label: Text(strings.lastMaintenanceShort), onSort: _onSort),
                    DataColumn(label: Text(strings.nextMaintenanceShort), onSort: _onSort),
                    DataColumn(label: Text(strings.actions)),
                  ],
                  rows: _filteredEquipments.map((equipment) {
                    return DataRow(
                      selected: _selectedEquipments.contains(equipment),
                      onSelectChanged: (selected) => setState(() => selected! ? _selectedEquipments.add(equipment) : _selectedEquipments.remove(equipment)),
                      cells: [
                        DataCell(Text(equipment.assetCode)),
                        DataCell(Text(equipment.name)),
                        DataCell(Text(equipment.type)),
                        DataCell(Text(equipment.brand)),
                        DataCell(Text(equipment.organizationId)),
                        DataCell(Text(equipment.status)),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(equipment.lastMaintenance))),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(equipment.nextMaintenance))),
                        DataCell(Row(children: [IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EquipmentEditScreen()))), IconButton(icon: const Icon(Icons.print), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PdfPreviewScreen(equipments: [equipment])))), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(equipment))])),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedEquipments.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PdfPreviewScreen(equipments: _selectedEquipments.toList()))),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text('Generate PDF for ${_selectedEquipments.length} items'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EquipmentEditScreen())), tooltip: strings.addEquipment, child: const Icon(Icons.add)),
    );
  }
}
