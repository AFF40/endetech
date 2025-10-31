import '../../constants/app_strings.dart';
import 'package:flutter/material.dart';

class MaintenanceProgrammingScreen extends StatefulWidget {
  const MaintenanceProgrammingScreen({super.key});

  @override
  State<MaintenanceProgrammingScreen> createState() =>
      _MaintenanceProgrammingScreenState();
}

class _MaintenanceProgrammingScreenState
    extends State<MaintenanceProgrammingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _technicianController = TextEditingController();
  final _maintenanceTypeController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _equipmentController.dispose();
    _technicianController.dispose();
    _maintenanceTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.scheduleMaintenance),
      ),
      body: SafeArea(
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
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: strings.date,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _equipmentController,
                          decoration: InputDecoration(
                            labelText: strings.equipment,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the equipment';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _technicianController,
                          decoration: InputDecoration(
                            labelText: strings.technician,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _maintenanceTypeController,
                          decoration: InputDecoration(
                            labelText: strings.maintenanceType,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: strings.description,
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saving Maintenance...')),
                              );
                            }
                          },
                          child: Text(
                            strings.save,
                            style: const TextStyle(fontSize: 16),
                          ),
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
