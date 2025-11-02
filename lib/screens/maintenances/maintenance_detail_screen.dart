import 'package:endetech/api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceDetails();
  }

  Future<void> _fetchMaintenanceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.getMantenimiento(widget.maintenanceId);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Mantenimiento'), // TODO: Internationalize
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
                      ElevatedButton(onPressed: _fetchMaintenanceDetails, child: const Text('Reintentar')), // TODO: Internationalize
                    ],
                  ),
                )
              : _maintenance == null
                  ? const Center(child: Text('No se encontraron detalles del mantenimiento.')) // TODO: Internationalize
                  : _buildDetails(),
    );
  }

  Widget _buildDetails() {
    final maintenance = _maintenance!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard('Equipo', [
            _buildDetailRow('Nombre:', maintenance.equipo?.nombre ?? 'N/A'),
            _buildDetailRow('Código:', maintenance.equipo?.codigo ?? 'N/A'),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard('Técnico', [
            _buildDetailRow('Nombre:', maintenance.tecnico?.fullName ?? 'N/A'),
            _buildDetailRow('Especialidad:', maintenance.tecnico?.especialidad ?? 'N/A'),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard('Detalles del Mantenimiento', [
            _buildDetailRow('Fecha Programada:', DateFormat('dd/MM/yyyy').format(maintenance.fechaProgramada)),
            _buildDetailRow('Estado:', maintenance.estado),
            _buildDetailRow('Observaciones:', maintenance.observaciones ?? 'Ninguna'),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard('Tareas', 
            maintenance.tareas.isNotEmpty
              ? maintenance.tareas.map((task) => Text('- ${task.nombre}')).toList()
              : [const Text('No hay tareas asignadas.')]
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
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
