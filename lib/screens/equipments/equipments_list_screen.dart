import '../../api_service.dart';
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
  final ApiService _apiService = ApiService();

  List<Equipment> _allEquipments = [];
  List<Equipment> _filteredEquipments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final _searchController = TextEditingController();
  final Set<Equipment> _selectedEquipments = {};
  int _sortColumnIndex = 7;
  bool _sortAscending = true;

  String? _selectedBrand;
  String? _selectedStatus;
  String? _selectedType;
  List<String> _uniqueBrands = [];
  List<String> _uniqueTypes = [];
  final List<String> _statuses = ['activo', 'en reparación'];

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
      _errorMessage = '';
    });

    final result = await _apiService.getEquipos();

    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data']['equipos'];
        setState(() {
          _allEquipments = data.map((json) => Equipment.fromJson(json)).toList();
          _uniqueBrands = _allEquipments.map((e) => e.marca).where((e) => e.isNotEmpty).toSet().toList();
          _uniqueTypes = _allEquipments.map((e) => e.tipo).where((e) => e.isNotEmpty).toSet().toList();
          
          if (!_uniqueBrands.contains(_selectedBrand)) {
            _selectedBrand = null;
          }
          if (!_uniqueTypes.contains(_selectedType)) {
            _selectedType = null;
          }

          _applyFilters();
          _isLoading = false;
        });
      } else {
        final strings = AppStrings.of(context);
        setState(() {
          _errorMessage = result['message'] ?? strings.errorLoadingData;
          _isLoading = false;
          _allEquipments = [];
          _filteredEquipments = [];
        });
      }
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
      int compareDates(DateTime? a, DateTime? b) {
        if (a == null && b == null) return 0;
        if (a == null) return 1; // nulls at end
        if (b == null) return -1;
        return a.compareTo(b);
      }

      int result = 0;
      switch (_sortColumnIndex) {
        case 0: result = a.codigo.compareTo(b.codigo); break;
        case 1: result = a.nombre.compareTo(b.nombre); break;
        case 2: result = a.tipo.compareTo(b.tipo); break;
        case 3: result = a.marca.compareTo(b.marca); break;
        case 4: result = (a.organization?.nombre ?? '').compareTo(b.organization?.nombre ?? ''); break;
        case 5: result = a.estado.compareTo(b.estado); break;
        case 6: result = compareDates(a.ultimoMantenimiento, b.ultimoMantenimiento); break;
        case 7: result = compareDates(a.proximoMantenimiento, b.proximoMantenimiento); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  Future<void> _deleteEquipment(int id) async {
    if (!mounted) return;
    final result = await _apiService.deleteEquipo(id);
    final strings = AppStrings.of(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['success'] 
            ? (result['data']?['message'] ?? strings.equipmentDeleted) 
            : result['message'] ?? strings.unexpectedErrorOccurred)),
      );
      if (result['success']) {
        _fetchEquipments();
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Equipment equipment, AppStrings strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text(strings.confirmDelete(equipment.nombre)),
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

  Color? _getRowColor(Equipment equipment) {
    if (equipment.proximoMantenimiento == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Convertir a hora local y normalizar (sin horas/minutos)
    final nextUtc = equipment.proximoMantenimiento!;
    final nextLocal = nextUtc.isUtc ? nextUtc.toLocal() : nextUtc;
    final next = DateTime(nextLocal.year, nextLocal.month, nextLocal.day);

    final daysUntilNext = next.difference(today).inDays;

    if (daysUntilNext < 0) {
      return Colors.red.withOpacity(0.5); // vencido
    } else if (daysUntilNext == 0) {
      return Colors.red.withOpacity(0.5); // hoy
    } else if (daysUntilNext <= 14) {
      return Colors.orange.withOpacity(0.4); // próximos 14 días
    } else if (daysUntilNext <= 28) {
      return Colors.yellow.withOpacity(0.4); // próximos 28 días
    }
    return null;
  }

  Widget _buildErrorView() {
    final strings = AppStrings.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchEquipments, child: Text(strings.retry)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.equipments)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
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
                      child: _filteredEquipments.isEmpty
                          ? Center(child: Text(strings.noResultsFound))
                          : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth, // se adapta al ancho del contenedor
                                maxWidth: constraints.maxWidth, // ocupa todo el ancho disponible
                              ),
                              child: DataTable(
                                columnSpacing: constraints.maxWidth * 0.02, // espacio relativo
                                headingRowHeight: 48,
                                dataRowHeight: 48,
                                sortColumnIndex: _sortColumnIndex,
                                sortAscending: _sortAscending,
                                onSelectAll: (selected) => setState(() => selected!
                                    ? _selectedEquipments.addAll(_filteredEquipments)
                                    : _selectedEquipments.clear()),
                                columns: [
                                  DataColumn(label: Text(strings.assetCode), onSort: _onSort),
                                  DataColumn(label: Text(strings.equipmentName), onSort: _onSort),
                                  DataColumn(label: Text(strings.type), onSort: _onSort),
                                  DataColumn(label: Text(strings.brand), onSort: _onSort),
                                  DataColumn(label: Text(strings.organizationManagement), onSort: _onSort),
                                  DataColumn(label: Text(strings.status), onSort: _onSort),
                                  DataColumn(label: Text(strings.lastMaintenanceShort), onSort: _onSort),
                                  DataColumn(label: Text(strings.nextMaintenanceShort), onSort: _onSort),
                                  DataColumn(label: Text(strings.actions)),
                                ],
                                rows: _filteredEquipments.map((equipment) {
                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                      return _getRowColor(equipment);
                                    }),
                                    selected: _selectedEquipments.contains(equipment),
                                    onSelectChanged: (selected) => setState(() => selected!
                                        ? _selectedEquipments.add(equipment)
                                        : _selectedEquipments.remove(equipment)),
                                    cells: [
                                      DataCell(Text(equipment.codigo)),
                                      DataCell(Text(equipment.nombre)),
                                      DataCell(Text(equipment.tipo)),
                                      DataCell(Text(equipment.marca)),
                                      DataCell(Text(equipment.organization?.nombre ?? strings.notAvailable)),
                                      DataCell(Text(equipment.estado)),
                                      DataCell(Text(equipment.ultimoMantenimiento != null
                                          ? DateFormat('dd/MM/yyyy').format(equipment.ultimoMantenimiento!)
                                          : '')),
                                      DataCell(Text(equipment.proximoMantenimiento != null
                                          ? DateFormat('dd/MM/yyyy').format(equipment.proximoMantenimiento!)
                                          : '')),
                                      DataCell(Row(
                                        children: [
                                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEditScreen(equipment)),
                                          IconButton(icon: const Icon(Icons.print), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PdfPreviewScreen(equipments: [equipment])))),
                                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(context, equipment, strings)),
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
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
                  label: Text(strings.generatePdfForN(_selectedEquipments.length, strings.equipments.toLowerCase())),
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
