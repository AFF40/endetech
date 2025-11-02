import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/maintenance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'maintenance_detail_screen.dart';
import 'maintenance_programming_screen.dart';
import '../reports/maintenance_pdf_preview_screen.dart';

class MaintenancesListScreen extends StatefulWidget {
  const MaintenancesListScreen({super.key});

  @override
  State<MaintenancesListScreen> createState() => _MaintenancesListScreenState();
}

class _MaintenancesListScreenState extends State<MaintenancesListScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();

  List<Maintenance> _allMaintenances = [];
  List<Maintenance> _filteredMaintenances = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final Set<Maintenance> _selectedMaintenances = {};
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  String? _selectedStatus;
  final List<String> _statuses = ['programado', 'en progreso', 'completado'];

  @override
  void initState() {
    super.initState();
    _fetchMaintenances();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaintenances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.getMantenimientos();

    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data']['mantenimientos'];
        setState(() {
          _allMaintenances = data.map((json) => Maintenance.fromJson(json)).toList();
          _applyFilters();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
          _allMaintenances = [];
          _filteredMaintenances = [];
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMaintenances = _allMaintenances.where((maintenance) {
        final matchesSearch = query.isEmpty ||
            (maintenance.equipo?.nombre.toLowerCase().contains(query) ?? false) ||
            (maintenance.equipo?.codigo.toLowerCase().contains(query) ?? false) ||
            (maintenance.tecnico?.fullName.toLowerCase().contains(query) ?? false);
        final matchesStatus = _selectedStatus == null || maintenance.estado == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
      _selectedMaintenances.removeWhere((item) => !_filteredMaintenances.contains(item));
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 5) return; // Action column is not sortable
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
        case 0: result = a.equipo?.codigo.compareTo(b.equipo?.codigo ?? '') ?? 0; break;
        case 1: result = a.equipo?.nombre.compareTo(b.equipo?.nombre ?? '') ?? 0; break;
        case 2: result = a.tecnico?.fullName.compareTo(b.tecnico?.fullName ?? '') ?? 0; break;
        case 3: result = a.fechaProgramada.compareTo(b.fechaProgramada); break;
        case 4: result = a.estado.compareTo(b.estado); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  Future<void> _deleteMaintenance(int id) async {
    final result = await _apiService.deleteMantenimiento(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['success'] 
            ? (result['data']?['message'] ?? 'Mantenimiento eliminado') 
            : result['message'])),
      );
      if (result['success']) {
        _fetchMaintenances();
      }
    }
  }

  void _showDeleteConfirmationDialog(Maintenance maintenance) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text('¿Estás seguro de que quieres eliminar el mantenimiento del equipo ${maintenance.equipo?.nombre ?? ''}?'), // TODO: Internationalize
          actions: <Widget>[
            TextButton(
              child: Text(strings.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteMaintenance(maintenance.id);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(Maintenance? maintenance) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceProgrammingScreen(maintenanceToEdit: maintenance),
      ),
    );
    if (result == true) {
      _fetchMaintenances();
    }
  }

  void _confirmChangeStatus(Maintenance maintenance, String newStatus) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.confirmAction),
          content: Text(strings.confirmCompleteMaintenance),
          actions: <Widget>[
            TextButton(child: Text(strings.cancel), onPressed: () => Navigator.of(dialogContext).pop(false)),
            TextButton(child: Text(strings.confirm), onPressed: () => Navigator.of(dialogContext).pop(true)),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      final result = await _apiService.updateMantenimiento(maintenance.id, {'estado': newStatus});
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success'] 
              ? (result['data']?['message'] ?? 'Estado actualizado') 
              : result['message'])),
        );
        if(result['success']) {
          _fetchMaintenances();
        }
      }
    }
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchMaintenances, child: const Text('Reintentar')), // TODO: Internationalize
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.maintenances)),
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
                      TextField(controller: _searchController, decoration: InputDecoration(hintText: strings.searchMaintenances, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), isDense: true)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        hint: Text(strings.allStatuses),
                        decoration: InputDecoration(labelText: strings.status, border: const OutlineInputBorder(), isDense: true),
                        onChanged: (val) => setState(() { _selectedStatus = val; _applyFilters(); }),
                        items: [
                          DropdownMenuItem(value: null, child: Text(strings.allStatuses)),
                          ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.characters.first.toUpperCase() + s.substring(1))))
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
                          DataColumn(label: Text(strings.assetCode), onSort: _onSort),
                          DataColumn(label: Text(strings.equipment), onSort: _onSort),
                          DataColumn(label: Text(strings.technician), onSort: _onSort),
                          DataColumn(label: Text(strings.date), onSort: _onSort),
                          DataColumn(label: Text(strings.status), onSort: _onSort),
                          DataColumn(label: Text(strings.actions)),
                        ],
                        rows: _filteredMaintenances.map((maintenance) {
                          return DataRow(
                            selected: _selectedMaintenances.contains(maintenance),
                            onSelectChanged: (selected) => setState(() => selected! ? _selectedMaintenances.add(maintenance) : _selectedMaintenances.remove(maintenance)),
                            cells: [
                              DataCell(Text(maintenance.equipo?.codigo ?? 'N/A')),
                              DataCell(Text(maintenance.equipo?.nombre ?? 'N/A')),
                              DataCell(Text(maintenance.tecnico?.fullName ?? 'N/A')),
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(maintenance.fechaProgramada))),
                              DataCell(Text(maintenance.estado)),
                              DataCell(Row(children: [
                                IconButton(icon: const Icon(Icons.visibility), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaintenanceDetailScreen(maintenanceId: maintenance.id)))),
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEditScreen(maintenance)),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () => _showDeleteConfirmationDialog(maintenance)),
                                IconButton(icon: const Icon(Icons.print), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaintenancePdfPreviewScreen(maintenances: [maintenance])))),
                                if (maintenance.estado != 'completado')
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    tooltip: strings.markAsCompleted,
                                    onPressed: () => _confirmChangeStatus(maintenance, 'completado'),
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
                  label: Text('Generar PDF para ${_selectedMaintenances.length} mantenimientos'), // TODO: Internationalize
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(onPressed: () => _navigateToEditScreen(null), tooltip: strings.addMaintenance, child: const Icon(Icons.add)),
    );
  }
}
