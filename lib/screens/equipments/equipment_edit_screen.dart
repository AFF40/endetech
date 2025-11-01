import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_service.dart';
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

    final isEditing = widget.equipment != null;
    final url = isEditing
        ? '${ApiService.equipos}/${widget.equipment!.id}'
        : ApiService.equipos;

    final body = {
      'codigo': _codigoController.text,
      'nombre': _nombreController.text,
      'tipo': _tipoController.text,
      'marca': _marcaController.text,
      'organization_id': _organizationIdController.text,
      'estado': _estadoController.text,
      'ultimo_mantenimiento': _ultimoMantenimientoController.text,
      'proximo_mantenimiento': _proximoMantenimientoController.text,
      'sistema_operativo': _sistemaOperativoController.text,
      'procesador': _procesadorController.text,
      'memoria_ram': _memoriaRamController.text,
      'almacenamiento': _almacenamientoController.text,
    };

    try {
      final response = isEditing
          ? await http.put(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
          : await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equipment saved successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save equipment: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                TextFormField(controller: _codigoController, decoration: InputDecoration(labelText: strings.assetCode, border: const OutlineInputBorder())), 
                const SizedBox(height: 16),
                TextFormField(controller: _nombreController, decoration: InputDecoration(labelText: strings.equipmentName, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _tipoController, decoration: InputDecoration(labelText: strings.type, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _marcaController, decoration: InputDecoration(labelText: strings.brand, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _organizationIdController, decoration: InputDecoration(labelText: strings.organizationId, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _estadoController, decoration: InputDecoration(labelText: strings.status, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _ultimoMantenimientoController, decoration: InputDecoration(labelText: strings.lastMaintenanceShort, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _proximoMantenimientoController, decoration: InputDecoration(labelText: strings.nextMaintenanceShort, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _sistemaOperativoController, decoration: InputDecoration(labelText: strings.so, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _procesadorController, decoration: InputDecoration(labelText: strings.processor, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _memoriaRamController, decoration: InputDecoration(labelText: strings.ram, border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                TextFormField(controller: _almacenamientoController, decoration: InputDecoration(labelText: strings.storage, border: const OutlineInputBorder())),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveEquipment,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(strings.save),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
