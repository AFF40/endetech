import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/equipment.dart';
import '../../models/maintenance.dart';
import '../../models/organization.dart';
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
  int _sortColumnIndex = 4;
  bool _sortAscending = true;

  String? _selectedStatus;
  final List<String> _statuses = ['pendiente', 'completado'];

  bool _didFetchData = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchData) {
      _fetchMaintenances();
      _didFetchData = true;
    }
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

    // Fetch maintenances and equipments in parallel
    final results = await Future.wait([
      _apiService.getMantenimientos(context),
      _apiService.getEquipos(context),
    ]);

    if (!mounted) return;

    final maintenanceResult = results[0];
    final equipmentResult = results[1];
    final strings = AppStrings.of(context);

    if (maintenanceResult['success'] && equipmentResult['success']) {
      final List<dynamic> maintenanceData = maintenanceResult['data']['mantenimientos'];
      final List<Maintenance> allMaintenances = maintenanceData.map((json) => Maintenance.fromJson(json)).toList();

      final List<dynamic> equipmentData = equipmentResult['data']['equipos'];
      final List<Equipment> allEquipments = equipmentData.map((json) => Equipment.fromJson(json)).toList();
      final Map<int, Organization?> equipmentOrgMap = {for (var e in allEquipments) e.id: e.organization};
      
      final updatedMaintenances = allMaintenances.map((maintenance) {
        if (maintenance.equipo != null) {
          final organization = equipmentOrgMap[maintenance.equipo!.id];
          if (organization != null) {
            final updatedEquipment = maintenance.equipo!.copyWith(organization: organization);
            return maintenance.copyWith(equipo: updatedEquipment);
          }
        }
        return maintenance;
      }).toList();

      setState(() {
        _allMaintenances = updatedMaintenances;
        if (_selectedStatus != null && !_statuses.contains(_selectedStatus)) {
          _selectedStatus = null;
        }
        _applyFilters();
        _isLoading = false;
      });

    } else {
      String errorMessage;
      if (!maintenanceResult['success']) {
        errorMessage = maintenanceResult['message'] ?? strings.errorLoadingData;
      } else {
        errorMessage = equipmentResult['message'] ?? strings.errorLoadingData;
      }
      
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
        _allMaintenances = [];
        _filteredMaintenances = [];
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMaintenances = _allMaintenances.where((maintenance) {
        final orgName = maintenance.equipo?.organization?.nombre.toLowerCase();
        final matchesSearch = query.isEmpty ||
            (maintenance.equipo?.nombre.toLowerCase().contains(query) ?? false) ||
            (maintenance.equipo?.codigo.toLowerCase().contains(query) ?? false) ||
            (maintenance.tecnico?.fullName.toLowerCase().contains(query) ?? false) ||
            (orgName?.contains(query) ?? false);
        final matchesStatus = _selectedStatus == null || maintenance.estado == _selectedStatus;
        return matchesSearch && matchesStatus;
      }).toList();
      _selectedMaintenances.removeWhere((item) => !_filteredMaintenances.contains(item));
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 6) return; // Action column is not sortable
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortFilteredList();
    });
  }

  void _sortFilteredList() {
    final strings = AppStrings.of(context);
    _filteredMaintenances.sort((a, b) {
      // If sorting by status column, let it be the primary sort criterion
      if (_sortColumnIndex == 5) {
        final result = a.estado.compareTo(b.estado);
        return _sortAscending ? result : -result;
      }

      // For any other column, first prioritize by status: 'pendiente' before 'completado'
      final statusA = a.estado == 'pendiente' ? 0 : 1;
      final statusB = b.estado == 'pendiente' ? 0 : 1;
      final statusCompare = statusA.compareTo(statusB);

      if (statusCompare != 0) {
        return statusCompare; // 'pendiente' comes first
      }

      // If statuses are the same, sort by the selected column
      int result = 0;
      switch (_sortColumnIndex) {
        case 0: result = (a.equipo?.codigo ?? '').compareTo(b.equipo?.codigo ?? ''); break;
        case 1: result = (a.equipo?.nombre ?? '').compareTo(b.equipo?.nombre ?? ''); break;
        case 2: result = (a.equipo?.organization?.nombre ?? '').compareTo(b.equipo?.organization?.nombre ?? ''); break;
        case 3: result = (a.tecnico?.fullName ?? strings.unassigned).compareTo(b.tecnico?.fullName ?? strings.unassigned); break;
        case 4: result = a.fechaProgramada.compareTo(b.fechaProgramada); break;
        // case 5 (status) is handled above, but other columns are the secondary criteria here
      }
      return _sortAscending ? result : -result;
    });
  }

  Future<void> _deleteMaintenance(int id) async {
    if (!mounted) return;
    final result = await _apiService.deleteMantenimiento(context, id);
    final strings = AppStrings.of(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['success'] 
            ? (result['data']?['message'] ?? strings.maintenanceDeleted) 
            : result['message'] ?? strings.unexpectedErrorOccurred)),
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
          content: Text(strings.confirmDelete('el mantenimiento del equipo ${maintenance.equipo?.nombre ?? strings.unassigned}')),
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
      final result = await _apiService.updateMantenimiento(context, maintenance.id, {'estado': newStatus});
      if(mounted) {
        final strings = AppStrings.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success'] 
              ? (result['data']?['message'] ?? strings.statusUpdated) 
              : result['message'] ?? strings.unexpectedErrorOccurred)),
        );
        if(result['success']) {
          _fetchMaintenances();
        }
      }
    }
  }

  Color? _getRowColor(Maintenance maintenance) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maintenanceDate = DateTime(
      maintenance.fechaProgramada.year,
      maintenance.fechaProgramada.month,
      maintenance.fechaProgramada.day,
    );
    final daysUntilNext = maintenanceDate.difference(today).inDays;
    if (maintenance.estado != 'completado') {
      if (daysUntilNext < 0) {
        return Colors.red.withOpacity(0.5); // Vencido
      } else if (daysUntilNext == 0) {
        return Colors.red.withOpacity(0.5); // Vence hoy
      } else if (daysUntilNext <= 14) {
        return Colors.orange.withOpacity(0.4); // Próximo a vencer (14 días)
      } else if (daysUntilNext <= 28) {
        return Colors.yellow.withOpacity(0.4); // Próximo a vencer (28 días)
      }
    }
    return null; // Sin color para completados o no próximos a vencer
  }


  Widget _buildErrorView() {
    final strings = AppStrings.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchMaintenances, child: Text(strings.retry)),
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
                    ],                  ),
                ),
                Expanded(
                  child: _filteredMaintenances.isEmpty
                      ? Center(child: Text(strings.noResultsFound))
                      : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
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
                                DataColumn(label: Text(strings.organization), onSort: _onSort),
                                DataColumn(label: Text(strings.technician), onSort: _onSort),
                                DataColumn(label: Text(strings.date), onSort: _onSort),
                                DataColumn(label: Text(strings.status), onSort: _onSort),
                                DataColumn(label: Text(strings.actions)),
                              ],
                              rows: _filteredMaintenances.map((maintenance) {
                                return DataRow(
                                  color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                    return _getRowColor(maintenance);
                                  }),
                                  selected: _selectedMaintenances.contains(maintenance),
                                  onSelectChanged: (selected) => setState(() => selected! ? _selectedMaintenances.add(maintenance) : _selectedMaintenances.remove(maintenance)),
                                  cells: [
                                    DataCell(Text(maintenance.equipo?.codigo ?? strings.notAvailable)),
                                    DataCell(Text(maintenance.equipo?.nombre ?? strings.notAvailable)),
                                    DataCell(Text(maintenance.equipo?.organization?.nombre ?? strings.notAvailable)),
                                    DataCell(Text(maintenance.tecnico?.fullName ?? strings.unassigned)),
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
                  label: Text(strings.generatePdfForN(_selectedMaintenances.length, strings.maintenances.toLowerCase())),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(null),
        tooltip: strings.scheduleMaintenance,
        child: const Icon(Icons.add),
      ),
    );
  }
}
