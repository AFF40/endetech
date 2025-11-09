import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/organization.dart';
import 'package:flutter/material.dart';

class OrganizationEditScreen extends StatefulWidget {
  final Organization? organization;

  const OrganizationEditScreen({super.key, this.organization});

  @override
  State<OrganizationEditScreen> createState() => _OrganizationEditScreenState();
}

class _OrganizationEditScreenState extends State<OrganizationEditScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.organization?.nombre ?? '');
    _descriptionController = TextEditingController(text: widget.organization?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveOrganization() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final data = {
      'nombre': _nameController.text,
      'descripcion': _descriptionController.text,
    };

    final isEditing = widget.organization != null;
    final result = isEditing
        ? await _apiService.updateOrganization(context, widget.organization!.id, data)
        : await _apiService.createOrganization(context, data);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      final strings = AppStrings.of(context);
      final message = result['success'] 
          ? (result['data']?['message'] ?? (isEditing ? strings.organizationUpdated : strings.organizationCreated))
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
      appBar: AppBar(
        title: Text(widget.organization == null ? strings.addOrganization : strings.registerEditOrganization),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: strings.name,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.fieldIsRequired; 
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: strings.description,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.pleaseEnterDescription;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveOrganization,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
