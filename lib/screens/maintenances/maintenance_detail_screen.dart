import 'package:endetech/api_service.dart';
import 'package:endetech/constants/app_strings.dart';
import 'package:endetech/models/maintenance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final int maintenanceId;
  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  @override
  State<MaintenanceDetailScreen> createState() => _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  final ApiService _apiService = ApiService();
  Maintenance? _maintenance;
  bool _isLoading = true;
  String _errorMessage = '';

  bool _didFetchData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchData) {
      _fetchMaintenanceDetails();
      _didFetchData = true;
    }
  }

  Future<void> _fetchMaintenanceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.getMantenimiento(context, widget.maintenanceId);

    if (mounted) {
      if (result['success']) {
        setState(() {
          _maintenance = Maintenance.fromJson(result['data']['mantenimiento']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.maintenanceDetailTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchMaintenanceDetails, child: Text(strings.retry)),
                    ],
                  ),
                )
              : _maintenance == null
                  ? Center(child: Text(strings.maintenanceDetailsNotFound))
                  : _buildDetails(strings),
    );
  }

  Widget _buildDetails(AppStrings strings) {
    final maintenance = _maintenance!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard(strings.equipmentLabel, [
            _buildDetailRow(strings.nameLabel, maintenance.equipo?.nombre ?? strings.notAvailable),
            _buildDetailRow(strings.codeLabel, maintenance.equipo?.codigo ?? strings.notAvailable),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard(strings.technicianLabel, [
            _buildDetailRow(strings.nameLabel, maintenance.tecnico?.fullName ?? strings.notAvailable),
            _buildDetailRow(strings.specialtyLabel, maintenance.tecnico?.especialidad ?? strings.notAvailable),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard(strings.maintenanceDetails, [
            _buildDetailRow(strings.scheduledDateLabel, DateFormat('dd/MM/yyyy').format(maintenance.fechaProgramada)),
            _buildDetailRow(strings.statusLabel, maintenance.estado),
            _buildDetailRow(strings.observationsLabel, maintenance.observaciones ?? strings.none),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard(strings.tasks, 
            maintenance.tareas.isNotEmpty
              ? maintenance.tareas.map((task) => Text('- ${task.nombre}')).toList()
              : [Text(strings.noTasksAssigned)]
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
