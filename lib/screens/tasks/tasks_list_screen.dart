import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/task.dart';
import 'package:flutter/material.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();

  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.getTareas();

    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data']['tareas'];
        setState(() {
          _allTasks = data.map((json) => Task.fromJson(json)).toList();
          _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        return task.nombre.toLowerCase().contains(query) ||
               (task.descripcion?.toLowerCase().contains(query) ?? false);
      }).toList();
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 2) return; // Actions column not sortable
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortFilteredList();
    });
  }

  void _sortFilteredList() {
    _filteredTasks.sort((a, b) {
      int result = 0;
      switch (_sortColumnIndex) {
        case 0: result = a.nombre.compareTo(b.nombre); break;
        case 1: result = (a.descripcion ?? '').compareTo(b.descripcion ?? ''); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  void _showTaskDialog({Task? task}) {
    final strings = AppStrings.of(context);
    final isEditing = task != null;
    final nameController = TextEditingController(text: isEditing ? task.nombre : '');
    final descriptionController = TextEditingController(text: isEditing ? task.descripcion : '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? strings.editTaskTemplate : strings.addTaskTemplate),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(labelText: strings.name),
                      validator: (value) => (value == null || value.isEmpty) ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: strings.description),
                       validator: (value) => (value == null || value.isEmpty) ? 'La descripción es requerida' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(strings.cancel)),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if(formKey.currentState!.validate()){
                      setDialogState(() => isSaving = true);

                      final data = {
                        'nombre': nameController.text,
                        'descripcion': descriptionController.text,
                      };

                      final result = isEditing
                          ? await _apiService.updateTarea(task.id, data)
                          : await _apiService.createTarea(data);

                      if(mounted){
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['success'] 
                                ? (result['data']?['message'] ?? (isEditing ? 'Tarea actualizada' : 'Tarea creada')) 
                                : result['message']))
                          );
                          if(result['success']){
                              _fetchTasks();
                          }
                      }
                    }
                  },
                  child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2,)) : Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Task taskToDelete) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.deleteTaskTemplate),
          content: Text(strings.deleteTaskConfirmation),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(strings.cancel)),
            TextButton(
              onPressed: () async {
                final result = await _apiService.deleteTarea(taskToDelete.id);
                if(mounted){
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['success'] 
                            ? (result['data']?['message'] ?? 'Tarea eliminada') 
                            : result['message']))
                    );
                    if(result['success']){
                        _fetchTasks();
                    }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(strings.delete),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchTasks, child: const Text('Reintentar')), // TODO: Internationalize
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.taskTemplates)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
            ? _buildErrorView()
            : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(hintText: strings.searchTasks, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), isDense: true),
                  ),
                ),
                Expanded(
                  child: _filteredTasks.isEmpty
                      ? const Center(child: Text('No se encontraron resultados')) // TODO: Internationalize
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                              child: DataTable(
                                sortColumnIndex: _sortColumnIndex,
                                sortAscending: _sortAscending,
                                columns: [
                                  DataColumn(label: Text(strings.name), onSort: _onSort),
                                  DataColumn(label: Text(strings.description), onSort: _onSort),
                                  DataColumn(label: Text(strings.actions)),
                                ],
                                rows: _filteredTasks.map((task) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(task.nombre)),
                                      DataCell(Text(task.descripcion ?? '')),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showTaskDialog(task: task), tooltip: 'Editar'),
                                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(task), tooltip: 'Eliminar'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showTaskDialog(), tooltip: strings.addTask, child: const Icon(Icons.add)),
    );
  }
}
