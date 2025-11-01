import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'equipment_edit_screen.dart';
import '../reports/pdf_preview_screen.dart';

class EquipmentsListScreen extends StatefulWidget {
  const EquipmentsListScreen({super.key});

  @override
  State<EquipmentsListScreen> createState() => _EquipmentsListScreenState();
}

class _EquipmentsListScreenState extends State<EquipmentsListScreen> {
  List<Equipment> _allEquipments = [];
  List<Equipment> _filteredEquipments = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  final Set<Equipment> _selectedEquipments = {};
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  String? _selectedBrand;
  String? _selectedStatus;
  String? _selectedType;
  List<String> _uniqueBrands = [];
  List<String> _uniqueTypes = [];
  final List<String> _statuses = ['activo', 'inactivo', 'en reparación'];

  @override
  void initState() {
    super.initState();
    _fetchEquipments();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEquipments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(ApiService.equipos));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('equipos') && body['equipos'] != null) {
          final List<dynamic> data = body['equipos'];
          _allEquipments = data.map((json) => Equipment.fromJson(json)).toList();
          _filteredEquipments = List.from(_allEquipments);
          // Dynamically populate filters
          _uniqueBrands = _allEquipments.map((e) => e.marca).toSet().toList();
          _uniqueTypes = _allEquipments.map((e) => e.tipo).toSet().toList();
        } else {
          _allEquipments = [];
          _filteredEquipments = [];
        }
      } else {
        throw Exception('Failed to load equipments');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching equipments: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEquipments = _allEquipments.where((equipment) {
        final matchesSearch = query.isEmpty ||
            equipment.nombre.toLowerCase().contains(query) ||
            equipment.codigo.toLowerCase().contains(query);
        final matchesBrand = _selectedBrand == null || equipment.marca == _selectedBrand;
        final matchesStatus = _selectedStatus == null || equipment.estado == _selectedStatus;
        final matchesType = _selectedType == null || equipment.tipo == _selectedType;
        return matchesSearch && matchesBrand && matchesStatus && matchesType;
      }).toList();
      _selectedEquipments.removeWhere((item) => !_filteredEquipments.contains(item));
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 8) return; // No sorting on actions column
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
        case 0: result = a.codigo.compareTo(b.codigo); break;
        case 1: result = a.nombre.compareTo(b.nombre); break;
        case 2: result = a.tipo.compareTo(b.tipo); break;
        case 3: result = a.marca.compareTo(b.marca); break;
        case 4: result = (a.organizationId?.toString() ?? '').compareTo(b.organizationId?.toString() ?? ''); break;
        case 5: result = a.estado.compareTo(b.estado); break;
        case 6: result = (a.ultimoMantenimiento ?? DateTime(0)).compareTo(b.ultimoMantenimiento ?? DateTime(0)); break;
        case 7: result = (a.proximoMantenimiento ?? DateTime(0)).compareTo(b.proximoMantenimiento ?? DateTime(0)); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  Future<void> _deleteEquipment(int id) async {
    final response = await http.delete(Uri.parse('${ApiService.equipos}/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      _fetchEquipments(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete equipment.')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Equipment equipment, AppStrings strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text('Are you sure you want to delete ${equipment.nombre}?'),
          actions: <Widget>[
            TextButton(child: Text(strings.cancel), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEquipment(equipment.id);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(Equipment? equipment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EquipmentEditScreen(equipment: equipment)),
    );
    if (result == true) {
      _fetchEquipments();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.equipments)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                              DataCell(Text(equipment.codigo)),
                              DataCell(Text(equipment.nombre)),
                              DataCell(Text(equipment.tipo)),
                              DataCell(Text(equipment.marca)),
                              DataCell(Text(equipment.organizationId?.toString() ?? '')),
                              DataCell(Text(equipment.estado)),
                              DataCell(Text(equipment.ultimoMantenimiento != null ? DateFormat('dd/MM/yyyy').format(equipment.ultimoMantenimiento!) : '')),
                              DataCell(Text(equipment.proximoMantenimiento != null ? DateFormat('dd/MM/yyyy').format(equipment.proximoMantenimiento!) : '')),
                              DataCell(Row(children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEditScreen(equipment)),
                                IconButton(icon: const Icon(Icons.print), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PdfPreviewScreen(equipments: [equipment])))),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(context, equipment, strings)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(null),
        tooltip: strings.addEquipment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
