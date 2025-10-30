import 'package:endetech/constants/app_strings.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scheduleMaintenance),
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
                          decoration: const InputDecoration(
                            labelText: AppStrings.date,
                            border: OutlineInputBorder(),
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
                          decoration: const InputDecoration(
                            labelText: AppStrings.equipment,
                            border: OutlineInputBorder(),
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
                          decoration: const InputDecoration(
                            labelText: AppStrings.technician,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _maintenanceTypeController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.maintenanceType,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.description,
                            border: OutlineInputBorder(),
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
                          child: const Text(
                            AppStrings.save,
                            style: TextStyle(fontSize: 16),
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
