import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_service.dart';
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

    final isEditing = widget.technician != null;
    final url = isEditing
        ? '${ApiService.tecnicos}/${widget.technician!.id}'
        : ApiService.tecnicos;

    final body = {
      'nombre': _nombreController.text,
      'primer_apellido': _primerApellidoController.text,
      'segundo_apellido': _segundoApellidoController.text,
      'especialidad': _especialidadController.text,
    };

    try {
      final response = isEditing
          ? await http.put(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
          : await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Technician saved successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save technician: ${response.body}')),
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
                decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _primerApellidoController,
                decoration: const InputDecoration(labelText: 'Primer Apellido', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a last name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _segundoApellidoController,
                decoration: const InputDecoration(labelText: 'Segundo Apellido (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _especialidadController,
                decoration: InputDecoration(labelText: strings.specialty, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveTechnician,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(strings.save),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
