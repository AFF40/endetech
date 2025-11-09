import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/equipment.dart';
import '../../models/organization.dart';
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
  
  // Controllers
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _tipoController;
  late TextEditingController _marcaController;
  late TextEditingController _sistemaOperativoController;
  late TextEditingController _procesadorController;
  late TextEditingController _memoriaRamController;
  late TextEditingController _almacenamientoController;
  
  // State variables
  String? _selectedEstado;
  int? _selectedOrganizationId;
  List<Organization> _organizations = [];
  bool _isLoadingData = true;
  String _errorMessage = '';
  bool _isSaving = false;

  final List<String> _estados = ['activo', 'en reparación'];

  bool _didFetchData = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchData) {
      _fetchInitialData();
      _didFetchData = true;
    }
  }

  Future<void> _fetchInitialData() async {
    final result = await _apiService.getOrganizations(context);
    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data']['organizations'];
        setState(() {
          _organizations = data.map((json) => Organization.fromJson(json)).toList();
          _isLoadingData = false;
        });
      } else {
        final strings = AppStrings.of(context);
        setState(() {
          _errorMessage = result['message'] ?? strings.errorLoadingData;
          _isLoadingData = false;
        });
      }
    }
  }

  void _initializeControllers() {
    _codigoController = TextEditingController(text: widget.equipment?.codigo ?? '');
    _nombreController = TextEditingController(text: widget.equipment?.nombre ?? '');
    _tipoController = TextEditingController(text: widget.equipment?.tipo ?? '');
    _marcaController = TextEditingController(text: widget.equipment?.marca ?? '');
    _selectedEstado = widget.equipment?.estado ?? 'activo';
    _selectedOrganizationId = widget.equipment?.organization?.id;
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
    _sistemaOperativoController.dispose();
    _procesadorController.dispose();
    _memoriaRamController.dispose();
    _almacenamientoController.dispose();
    super.dispose();
  }

  Future<void> _saveEquipment() async {
    if (!_formKey.currentState!.validate()) return;
    final strings = AppStrings.of(context);

    setState(() {
      _isSaving = true;
    });

    final data = {
      'codigo': _codigoController.text,
      'nombre': _nombreController.text,
      'tipo': _tipoController.text,
      'marca': _marcaController.text,
      'organization_id': _selectedOrganizationId,
      'estado': _selectedEstado,
      'sistema_operativo': _sistemaOperativoController.text,
      'procesador': _procesadorController.text,
      'memoria_ram': _memoriaRamController.text,
      'almacenamiento': _almacenamientoController.text,
    };
    
    data.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    final isEditing = widget.equipment != null;
    final result = isEditing
        ? await _apiService.updateEquipo(context, widget.equipment!.id, data)
        : await _apiService.createEquipo(context, data);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      final message = result['success'] 
          ? (result['data']?['message'] ?? (isEditing ? strings.equipmentUpdated : strings.equipmentCreated))
          : result['message'] ?? strings.unexpectedErrorOccurred;

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
      body: _isLoadingData
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _codigoController,
                                decoration: InputDecoration(labelText: strings.assetCode, border: const OutlineInputBorder()),
                                validator: (value) => (value == null || value.isEmpty) ? strings.fieldIsRequired : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _nombreController, 
                                decoration: InputDecoration(labelText: strings.equipmentName, border: const OutlineInputBorder()),
                                validator: (value) => (value == null || value.isEmpty) ? strings.fieldIsRequired : null,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _selectedOrganizationId,
                                decoration: InputDecoration(labelText: strings.organizationManagement, border: const OutlineInputBorder()),
                                items: _organizations.map((Organization org) {
                                  return DropdownMenuItem<int>(
                                    value: org.id,
                                    child: Text(org.nombre),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedOrganizationId = newValue;
                                  });
                                },
                                validator: (value) => (value == null) ? strings.pleaseSelectAnOrganization : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(controller: _tipoController, decoration: InputDecoration(labelText: strings.type, border: const OutlineInputBorder())),
                              const SizedBox(height: 16),
                              TextFormField(controller: _marcaController, decoration: InputDecoration(labelText: strings.brand, border: const OutlineInputBorder())),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedEstado,
                                decoration: InputDecoration(labelText: strings.status, border: const OutlineInputBorder()),
                                items: _estados.map((String estado) {
                                  return DropdownMenuItem<String>(
                                    value: estado,
                                    child: Text(estado.characters.first.toUpperCase() + estado.substring(1)),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedEstado = newValue;
                                  });
                                },
                                validator: (value) => (value == null || value.isEmpty) ? strings.fieldIsRequired : null,
                              ),
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
                                onPressed: _isSaving ? null : _saveEquipment,
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                                child: _isSaving
                                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                                    : Text(strings.save),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
