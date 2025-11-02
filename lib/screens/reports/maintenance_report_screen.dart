import 'package:endetech/api_service.dart';
import 'package:endetech/constants/app_strings.dart';
import 'package:endetech/models/equipment.dart';
import 'package:endetech/models/maintenance.dart';
import 'package:endetech/models/organization.dart';
import 'package:endetech/models/technician.dart';
import 'package:endetech/screens/reports/maintenance_pdf_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceReportScreen extends StatefulWidget {
  const MaintenanceReportScreen({super.key});

  @override
  State<MaintenanceReportScreen> createState() => _MaintenanceReportScreenState();
}

class _MaintenanceReportScreenState extends State<MaintenanceReportScreen> {
  final ApiService _apiService = ApiService();

  // Data for filters
  List<Technician> _technicians = [];
  List<Equipment> _equipments = [];
  List<Maintenance> _allMaintenances = [];

  // Selected filter values
  int? _selectedTechnicianId;
  int? _selectedEquipmentId;
  DateTime? _startDate;
  DateTime? _endDate;

  // Results
  List<Maintenance> _filteredMaintenances = [];
  final Set<Maintenance> _selectedMaintenances = {};

  // UI State
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFilterData();
  }

  Future<void> _fetchFilterData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        _apiService.getTecnicos(),
        _apiService.getEquipos(),
        _apiService.getMantenimientos(),
      ]);

      if (!mounted) return;

      final techniciansResult = results[0];
      final equipmentsResult = results[1];
      final maintenancesResult = results[2];

      final strings = AppStrings.of(context);
      if (!techniciansResult['success'] || !equipmentsResult['success'] || !maintenancesResult['success']) {
        setState(() {
          _errorMessage = techniciansResult['message'] ?? equipmentsResult['message'] ?? maintenancesResult['message'] ?? strings.errorLoadingData;
          _isLoading = false;
        });
        return;
      }

      final List<Technician> technicians = (techniciansResult['data']['tecnicos'] as List).map((t) => Technician.fromJson(t)).toList();
      final List<Equipment> equipments = (equipmentsResult['data']['equipos'] as List).map((e) => Equipment.fromJson(e)).toList();
      final List<Maintenance> allMaintenances = (maintenancesResult['data']['mantenimientos'] as List).map((m) => Maintenance.fromJson(m)).toList();

      final Map<int, Organization?> equipmentOrgMap = {for (var e in equipments) e.id: e.organization};

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
        _technicians = technicians;
        _equipments = equipments;
        _allMaintenances = updatedMaintenances;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        final strings = AppStrings.of(context);
        setState(() {
          _errorMessage = strings.unexpectedErrorOccurred;
          _isLoading = false;
        });
      }
    }
  }

  void _generateReport() {
    setState(() {
      _selectedMaintenances.clear();
      _filteredMaintenances = _allMaintenances.where((maint) {
        final maintDate = maint.fechaProgramada;
        final isAfterStartDate = _startDate == null || !maintDate.isBefore(_startDate!);
        final isBeforeEndDate = _endDate == null || maintDate.isBefore(_endDate!.add(const Duration(days: 1)));
        final matchesTechnician = _selectedTechnicianId == null || maint.tecnico?.id == _selectedTechnicianId;
        final matchesEquipment = _selectedEquipmentId == null || maint.equipo?.id == _selectedEquipmentId;
        return isAfterStartDate && isBeforeEndDate && matchesTechnician && matchesEquipment;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final initialDate = isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = isStartDate ? DateTime(2020) : (_startDate ?? DateTime(2020));
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.maintenanceReport)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildFilters(context, strings),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _generateReport,
                            icon: const Icon(Icons.search),
                            label: Text(strings.generateReport),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredMaintenances.isEmpty
                          ? Center(child: Text(strings.noResultsFound))
                          : _buildResultsTable(strings),
                    ),
                  ],
                ),
      bottomNavigationBar: _selectedMaintenances.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaintenancePdfPreviewScreen(maintenances: _selectedMaintenances.toList()),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(strings.generatePdfForN(_selectedMaintenances.length, strings.maintenances.toLowerCase())),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFilters(BuildContext context, AppStrings strings) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _selectedTechnicianId,
          hint: Text(strings.allTechnicians),
          decoration: InputDecoration(labelText: strings.technician, border: const OutlineInputBorder()),
          items: [
            DropdownMenuItem<int>(value: null, child: Text(strings.allTechnicians)),
            ..._technicians.map((t) => DropdownMenuItem(value: t.id, child: Text(t.fullName))),
          ],
          onChanged: (val) => setState(() => _selectedTechnicianId = val),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedEquipmentId,
          hint: Text(strings.allEquipments),
          decoration: InputDecoration(labelText: strings.equipment, border: const OutlineInputBorder()),
          items: [
            DropdownMenuItem<int>(value: null, child: Text(strings.allEquipments)),
            ..._equipments.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.nombre} (${e.codigo})'))),
          ],
          onChanged: (val) => setState(() => _selectedEquipmentId = val),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isStartDate: true),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: strings.startDate, border: const OutlineInputBorder()),
                  child: Text(_startDate != null ? DateFormat.yMd().format(_startDate!) : ' '),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isStartDate: false),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: strings.endDate, border: const OutlineInputBorder()),
                  child: Text(_endDate != null ? DateFormat.yMd().format(_endDate!) : ' '),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsTable(AppStrings strings) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          onSelectAll: (isSelected) {
            if (isSelected ?? false) {
              setState(() => _selectedMaintenances.addAll(_filteredMaintenances));
            } else {
              setState(() => _selectedMaintenances.clear());
            }
          },
          columns: [
            DataColumn(label: Text(strings.date)),
            DataColumn(label: Text(strings.organizationManagement)),
            DataColumn(label: Text(strings.equipment)),
            DataColumn(label: Text(strings.technician)),
            DataColumn(label: Text(strings.characteristics)),
            DataColumn(label: Text(strings.tasks)),
            DataColumn(label: Text(strings.observations)),
            DataColumn(label: Text(strings.status)),
          ],
          rows: _filteredMaintenances.map((maint) {
             final characteristics = [
              if (maint.equipo?.sistemaOperativo != null) 'SO: ${maint.equipo!.sistemaOperativo}',
              if (maint.equipo?.procesador != null) 'CPU: ${maint.equipo!.procesador}',
              if (maint.equipo?.memoriaRam != null) 'RAM: ${maint.equipo!.memoriaRam}',
              if (maint.equipo?.almacenamiento != null) 'Almacenamiento: ${maint.equipo!.almacenamiento}',
            ].join(', ');

            return DataRow(
              selected: _selectedMaintenances.contains(maint),
              onSelectChanged: (isSelected) {
                setState(() {
                  if (isSelected ?? false) {
                    _selectedMaintenances.add(maint);
                  } else {
                    _selectedMaintenances.remove(maint);
                  }
                });
              },
              cells: [
                DataCell(Text(DateFormat('dd/MM/yyyy').format(maint.fechaProgramada))),
                DataCell(Text(maint.equipo?.organization?.nombre ?? strings.notAvailable)),
                DataCell(Text(maint.equipo?.nombre ?? strings.notAvailable)),
                DataCell(Text(maint.tecnico?.fullName ?? strings.unassigned)),
                DataCell(Text(characteristics.isNotEmpty ? characteristics : strings.notAvailable)),
                DataCell(Text(maint.tareas.isNotEmpty ? maint.tareas.map((t) => t.nombre).join(', ') : strings.none)),
                DataCell(Text(maint.observaciones ?? strings.none)),
                DataCell(Text(maint.estado)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
