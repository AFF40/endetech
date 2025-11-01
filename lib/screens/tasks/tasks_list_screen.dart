import 'dart:convert';
import 'package:endetech/api/api_service.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_strings.dart';
import '../../models/task.dart';
import 'package:flutter/material.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final _searchController = TextEditingController();

  List<Task> _allTasks = [];
  late List<Task> _filteredTasks;
  bool _isLoading = true;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredTasks = [];
    _fetchTasks();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _fetchTasks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(ApiService.tareas));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('tareas') && body['tareas'] != null) {
          final List<dynamic> data = body['tareas'];
          if (mounted) {
            setState(() {
              _allTasks = data.map((json) => Task.fromJson(json)).toList();
              _filteredTasks = List.from(_allTasks);
              _onSort(0, true);
            });
          }
        }
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        return task.nombre.toLowerCase().contains(query) ||
               task.descripcion.toLowerCase().contains(query);
      }).toList();
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 2) return; // Actions column is not sortable
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
        case 1: result = a.descripcion.compareTo(b.descripcion); break;
      }
      return _sortAscending ? result : -result;
    });
  }

  void _showTaskDialog({Task? task}) {
    final strings = AppStrings.of(context);
    final isEditing = task != null;
    final nameController = TextEditingController(text: isEditing ? task.nombre : '');
    final descriptionController = TextEditingController(text: isEditing ? task.descripcion : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? strings.editTaskTemplate : strings.addTaskTemplate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(labelText: strings.name),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: strings.description),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final description = descriptionController.text;
                if (name.isNotEmpty && description.isNotEmpty) {
                  final url = isEditing ? ApiService.updateTarea(task.id) : ApiService.tareas;
                  final body = json.encode({'nombre': name, 'descripcion': description});
                  final headers = {'Content-Type': 'application/json'};

                  try {
                    final response = await http.post(Uri.parse(url), headers: headers, body: body);
                    if (response.statusCode == 200 || response.statusCode == 201) {
                      Navigator.pop(context);
                      _fetchTasks(); 
                    } else {
                      // Handle error
                    }
                  } catch (e) {
                    // Handle error
                  }
                }
              },
              child: Text(strings.save),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Task taskToDelete) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.deleteTaskTemplate),
          content: Text(strings.deleteTaskConfirmation),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
            TextButton(
              onPressed: () async {
                try {
                  final response = await http.delete(Uri.parse(ApiService.tareaById(taskToDelete.id)));
                  if (response.statusCode == 200 || response.statusCode == 204) {
                    Navigator.pop(context);
                    _fetchTasks();
                  } else {
                    // handle error
                  }
                } catch (e) {
                  // handle error
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

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.taskTemplates)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  child: SingleChildScrollView(
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
                                DataCell(Text(task.descripcion)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showTaskDialog(task: task), tooltip: 'Edit'),
                                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(task), tooltip: 'Delete'),
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
      floatingActionButton: FloatingActionButton(onPressed: _showTaskDialog, tooltip: strings.addTask, child: const Icon(Icons.add)),
    );
  }
}
