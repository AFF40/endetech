import '../../constants/app_strings.dart';
import 'package:flutter/material.dart';

// A simple data class for the task template
class _TaskTemplate {
  String description;
  _TaskTemplate({required this.description});
}

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final _searchController = TextEditingController();

  // The master list of task templates
  final List<_TaskTemplate> _allTasks = [
    _TaskTemplate(description: 'Actualizar Firma Email'),
    _TaskTemplate(description: 'Desfragmentación Disco'),
    _TaskTemplate(description: 'Eliminación de temporales'),
    _TaskTemplate(description: 'Limpiar cache navegador'),
    _TaskTemplate(description: 'Actualización de Windows'),
    _TaskTemplate(description: 'Actualización Antivirus'),
    _TaskTemplate(description: 'Limpieza física (suciedad)'),
    _TaskTemplate(description: 'Cambio de pasta térmica'),
    _TaskTemplate(description: 'Verificar pantalla'),
    _TaskTemplate(description: 'Verificar periféricos'),
    _TaskTemplate(description: 'Cambio de periféricos de ser necesario'),
    _TaskTemplate(description: 'Ordenamiento de cables'),
    _TaskTemplate(description: 'Montaje y funcionamiento del equipo'),
  ];

  late List<_TaskTemplate> _filteredTasks;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredTasks = List.from(_allTasks);
    _searchController.addListener(_applyFilters);
    _onSort(0, true); // Initial sort
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
        return task.description.toLowerCase().contains(query);
      }).toList();
      _sortFilteredList();
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    if (columnIndex == 1) return;
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortFilteredList();
    });
  }

  void _sortFilteredList() {
    _filteredTasks.sort((a, b) {
      if (_sortColumnIndex == 0) {
        return _sortAscending
            ? a.description.compareTo(b.description)
            : b.description.compareTo(a.description);
      }
      return 0;
    });
  }

  void _showTaskDialog({_TaskTemplate? task}) {
    final strings = AppStrings.of(context);
    final isEditing = task != null;
    final textController = TextEditingController(text: isEditing ? task.description : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? strings.editTaskTemplate : strings.addTaskTemplate),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(labelText: strings.taskDescription),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
            ElevatedButton(
              onPressed: () {
                final newDescription = textController.text;
                if (newDescription.isNotEmpty) {
                  setState(() {
                    if (isEditing) {
                      task.description = newDescription;
                    } else {
                      _allTasks.add(_TaskTemplate(description: newDescription));
                    }
                    _applyFilters();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(strings.save),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(_TaskTemplate taskToDelete) {
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
              onPressed: () {
                setState(() {
                  _allTasks.remove(taskToDelete);
                  _applyFilters();
                });
                Navigator.pop(context);
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
      body: Column(
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
                      DataColumn(label: Text(strings.taskDescription), onSort: _onSort),
                      DataColumn(label: Text(strings.actions)),
                    ],
                    rows: _filteredTasks.map((task) {
                      return DataRow(
                        cells: [
                          DataCell(Text(task.description)),
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
