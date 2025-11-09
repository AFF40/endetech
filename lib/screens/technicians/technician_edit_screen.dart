import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/technician.dart';
import 'package:flutter/material.dart';

class TechnicianEditScreen extends StatefulWidget {
  final Technician? technician;

  const TechnicianEditScreen({super.key, this.technician});

  @override
  State<TechnicianEditScreen> createState() => _TechnicianEditScreenState();
}

class _TechnicianEditScreenState extends State<TechnicianEditScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _primerApellidoController;
  late TextEditingController _segundoApellidoController;
  late TextEditingController _especialidadController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.technician?.nombre ?? '');
    _primerApellidoController = TextEditingController(text: widget.technician?.primerApellido ?? '');
    _segundoApellidoController = TextEditingController(text: widget.technician?.segundoApellido ?? '');
    _especialidadController = TextEditingController(text: widget.technician?.especialidad ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _especialidadController.dispose();
    super.dispose();
  }

  Future<void> _saveTechnician() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final data = {
      'nombre': _nombreController.text,
      'primer_apellido': _primerApellidoController.text,
      'segundo_apellido': _segundoApellidoController.text,
      'especialidad': _especialidadController.text,
    };

    final isEditing = widget.technician != null;
    final result = isEditing
        ? await _apiService.updateTecnico(context, widget.technician!.id, data)
        : await _apiService.createTecnico(context, data);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      final strings = AppStrings.of(context);
      final message = result['success'] 
          ? (result['data']?['message'] ?? (isEditing ? strings.technicianUpdated : strings.technicianCreated))
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
      appBar: AppBar(title: Text(widget.technician == null ? strings.addTechnician : strings.registerEditTechnician)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: strings.name, border: const OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? strings.firstNameRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _primerApellidoController,
                decoration: InputDecoration(labelText: strings.firstName, border: const OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? strings.lastNameRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _segundoApellidoController,
                decoration: InputDecoration(labelText: strings.secondNameOptional, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _especialidadController,
                decoration: InputDecoration(labelText: strings.specialty, border: const OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? strings.specialtyRequired : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTechnician,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : Text(strings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
