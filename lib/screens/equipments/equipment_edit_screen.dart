import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EquipmentEditScreen extends StatefulWidget {
  final Equipment? equipment;

  const EquipmentEditScreen({super.key, this.equipment});

  @override
  State<EquipmentEditScreen> createState() => _EquipmentEditScreenState();
}

class _EquipmentEditScreenState extends State<EquipmentEditScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _tipoController;
  late TextEditingController _marcaController;
  late TextEditingController _organizationIdController;
  late TextEditingController _estadoController;
  late TextEditingController _ultimoMantenimientoController;
  late TextEditingController _proximoMantenimientoController;
  late TextEditingController _sistemaOperativoController;
  late TextEditingController _procesadorController;
  late TextEditingController _memoriaRamController;
  late TextEditingController _almacenamientoController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.equipment?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.equipment?.nombre ?? '');
    _tipoController = TextEditingController(text: widget.equipment?.tipo ?? '');
    _marcaController = TextEditingController(text: widget.equipment?.marca ?? '');
    _organizationIdController = TextEditingController(text: widget.equipment?.organizationId?.toString() ?? '');
    _estadoController = TextEditingController(text: widget.equipment?.estado ?? '');
    _ultimoMantenimientoController = TextEditingController(text: widget.equipment?.ultimoMantenimiento != null ? DateFormat('yyyy-MM-dd').format(widget.equipment!.ultimoMantenimiento!) : '');
    _proximoMantenimientoController = TextEditingController(text: widget.equipment?.proximoMantenimiento != null ? DateFormat('yyyy-MM-dd').format(widget.equipment!.proximoMantenimiento!) : '');
    _sistemaOperativoController = TextEditingController(text: widget.equipment?.sistemaOperativo ?? '');
    _procesadorController = TextEditingController(text: widget.equipment?.procesador ?? '');
    _memoriaRamController = TextEditingController(text: widget.equipment?.memoriaRam ?? '');
    _almacenamientoController = TextEditingController(text: widget.equipment?.almacenamiento ?? '');
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _tipoController.dispose();
    _marcaController.dispose();
    _organizationIdController.dispose();
    _estadoController.dispose();
    _ultimoMantenimientoController.dispose();
    _proximoMantenimientoController.dispose();
    _sistemaOperativoController.dispose();
    _procesadorController.dispose();
    _memoriaRamController.dispose();
    _almacenamientoController.dispose();
    super.dispose();
  }

  Future<void> _saveEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final data = {
      'codigo': _codigoController.text,
      'nombre': _nombreController.text,
      'tipo': _tipoController.text,
      'marca': _marcaController.text,
      'organization_id': int.tryParse(_organizationIdController.text),
      'estado': _estadoController.text,
      'ultimo_mantenimiento': _ultimoMantenimientoController.text,
      'proximo_mantenimiento': _proximoMantenimientoController.text,
      'sistema_operativo': _sistemaOperativoController.text,
      'procesador': _procesadorController.text,
      'memoria_ram': _memoriaRamController.text,
      'almacenamiento': _almacenamientoController.text,
    };
    
    data.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    final isEditing = widget.equipment != null;
    final result = isEditing
        ? await _apiService.updateEquipo(widget.equipment!.id, data)
        : await _apiService.createEquipo(data);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      final message = result['success'] 
          ? (result['data']?['message'] ?? (isEditing ? 'Equipo actualizado' : 'Equipo creado'))
          : result['message'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      if (result['success']) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.equipment == null ? strings.addEquipment : strings.registerEditEquipment)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _codigoController,
                  decoration: InputDecoration(labelText: strings.assetCode, border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null, // TODO: Internationalize
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController, 
                  decoration: InputDecoration(labelText: strings.equipmentName, border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null, // TODO: Internationalize
                ),
                const SizedBox(height: 16),
                TextFormField(controller: _tipoController, decoration: InputDecoration(labelText: strings.type, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _marcaController, decoration: InputDecoration(labelText: strings.brand, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _organizationIdController,
                  decoration: InputDecoration(labelText: strings.organizationId, border: const OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return 'Debe ser un número válido'; // TODO: Internationalize
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _estadoController,
                  decoration: InputDecoration(labelText: strings.status, border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null, // TODO: Internationalize
                ),
                const SizedBox(height: 16),
                TextFormField(controller: _ultimoMantenimientoController, decoration: InputDecoration(labelText: strings.lastMaintenanceShort, hintText: 'YYYY-MM-DD', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _proximoMantenimientoController, decoration: InputDecoration(labelText: strings.nextMaintenanceShort, hintText: 'YYYY-MM-DD', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _sistemaOperativoController, decoration: InputDecoration(labelText: strings.so, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _procesadorController, decoration: InputDecoration(labelText: strings.processor, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _memoriaRamController, decoration: InputDecoration(labelText: strings.ram, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _almacenamientoController, decoration: InputDecoration(labelText: strings.storage, border: const OutlineInputBorder())),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveEquipment,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : Text(strings.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
