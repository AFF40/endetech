import 'package:endetech/constants/app_strings.dart';
import 'package:flutter/material.dart';

class EquipmentEditScreen extends StatefulWidget {
  const EquipmentEditScreen({super.key});

  @override
  State<EquipmentEditScreen> createState() => _EquipmentEditScreenState();
}

class _EquipmentEditScreenState extends State<EquipmentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _soController = TextEditingController();
  final _hostnameController = TextEditingController();
  final _processorController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _brandController = TextEditingController();
  final _typeController = TextEditingController();
  final _assetCodeController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _soController.dispose();
    _hostnameController.dispose();
    _processorController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _brandController.dispose();
    _typeController.dispose();
    _assetCodeController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerEditEquipment),
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
                          controller: _soController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.so,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Operating System';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _hostnameController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.hostname,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Hostname';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _processorController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.processor,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ramController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.ram,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _storageController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.storage,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.brand,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _typeController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.type,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _assetCodeController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.assetCode,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Asset Code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.unit,
                            border: OutlineInputBorder(),
                          ),
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
                                const SnackBar(content: Text('Saving Equipment...')),
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
