import 'package:endetech/constants/app_strings.dart';
import 'package:endetech/screens/equipments/equipment_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Updated data class to match your specifications
class _Equipment {
  const _Equipment({
    required this.assetCode,
    required this.name,
    required this.type,
    required this.brand,
    required this.organizationId,
    required this.status,
    required this.lastMaintenance,
    required this.nextMaintenance,
  });
  final String assetCode;
  final String name;
  final String type;
  final String brand;
  final String organizationId;
  final String status;
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
}

class EquipmentsListScreen extends StatefulWidget {
  const EquipmentsListScreen({super.key});

  @override
  State<EquipmentsListScreen> createState() => _EquipmentsListScreenState();
}

class _EquipmentsListScreenState extends State<EquipmentsListScreen> {
  final _searchController = TextEditingController();

  // Sample data updated with new fields
  final List<_Equipment> _allEquipments = [
    _Equipment(assetCode: 'EQ-001', name: 'Laptop Financiero 01', type: 'Laptop', brand: 'HP', organizationId: 'FIN-01', status: 'Active', lastMaintenance: DateTime(2023, 10, 15), nextMaintenance: DateTime(2024, 4, 15)),
    _Equipment(assetCode: 'EQ-002', name: 'Laptop Marketing 02', type: 'Laptop', brand: 'Dell', organizationId: 'MKT-02', status: 'Active', lastMaintenance: DateTime(2023, 11, 20), nextMaintenance: DateTime(2024, 5, 20)),
    _Equipment(assetCode: 'EQ-003', name: 'PC Desarrollo 03', type: 'Desktop', brand: 'Lenovo', organizationId: 'DEV-03', status: 'In Repair', lastMaintenance: DateTime(2023, 9, 1), nextMaintenance: DateTime(2024, 3, 1)),
    _Equipment(assetCode: 'EQ-004', name: 'Servidor Base de Datos', type: 'Server', brand: 'Dell', organizationId: 'SRV-01', status: 'Active', lastMaintenance: DateTime(2023, 12, 5), nextMaintenance: DateTime(2024, 6, 5)),
    _Equipment(assetCode: 'EQ-005', name: 'Laptop RRHH 04', type: 'Laptop', brand: 'HP', organizationId: 'HR-04', status: 'Inactive', lastMaintenance: DateTime(2023, 8, 10), nextMaintenance: DateTime(2024, 2, 10)),
    _Equipment(assetCode: 'EQ-006', name: 'PC Diseño 05', type: 'Desktop', brand: 'Apple', organizationId: 'DSN-05', status: 'Active', lastMaintenance: DateTime(2023, 10, 25), nextMaintenance: DateTime(2024, 4, 25)),
  ];

  late List<_Equipment> _filteredEquipments;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // State for filters
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
      _filteredEquipments = _allEquipments.where((equipment) {
        final matchesSearch = query.isEmpty ||
            equipment.name.toLowerCase().contains(query) ||
            equipment.assetCode.toLowerCase().contains(query);
        
        final matchesBrand = _selectedBrand == null || equipment.brand == _selectedBrand;
        final matchesStatus = _selectedStatus == null || equipment.status == _selectedStatus;
        final matchesType = _selectedType == null || equipment.type == _selectedType;

        return matchesSearch && matchesBrand && matchesStatus && matchesType;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.equipments)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchEquipments,
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
                        value: _selectedBrand,
                        hint: const Text(AppStrings.allBrands),
                        onChanged: (val) => setState(() { _selectedBrand = val; _applyFilters(); }),
                        items: [ const DropdownMenuItem(value: null, child: Text(AppStrings.allBrands)), ..._uniqueBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))) ],
                        decoration: const InputDecoration(labelText: AppStrings.brand, border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        hint: const Text(AppStrings.allStatuses),
                        onChanged: (val) => setState(() { _selectedStatus = val; _applyFilters(); }),
                        items: [ const DropdownMenuItem(value: null, child: Text(AppStrings.allStatuses)), ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))) ],
                        decoration: const InputDecoration(labelText: AppStrings.status, border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                 const SizedBox(height: 12),
                 DropdownButtonFormField<String>(
                    value: _selectedType,
                    hint: const Text(AppStrings.allTypes),
                    onChanged: (val) => setState(() { _selectedType = val; _applyFilters(); }),
                    items: [ const DropdownMenuItem(value: null, child: Text(AppStrings.allTypes)), ..._uniqueTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))) ],
                    decoration: const InputDecoration(labelText: AppStrings.type, border: OutlineInputBorder(), isDense: true),
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
                  DataColumn(label: const Text(AppStrings.assetCode), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.equipmentName), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.type), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.brand), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.organizationId), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.status), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.lastMaintenanceShort), onSort: _onSort),
                  DataColumn(label: const Text(AppStrings.nextMaintenanceShort), onSort: _onSort),
                  const DataColumn(label: Text(AppStrings.actions)),
                ],
                rows: _filteredEquipments.map((equipment) {
                  return DataRow(
                    cells: [
                      DataCell(Text(equipment.assetCode)),
                      DataCell(Text(equipment.name)),
                      DataCell(Text(equipment.type)),
                      DataCell(Text(equipment.brand)),
                      DataCell(Text(equipment.organizationId)),
                      DataCell(Text(equipment.status)),
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(equipment.lastMaintenance))),
                      DataCell(Text(DateFormat('dd/MM/yyyy').format(equipment.nextMaintenance))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EquipmentEditScreen()),
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
            MaterialPageRoute(builder: (context) => const EquipmentEditScreen()),
          );
        },
        tooltip: AppStrings.addEquipment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
