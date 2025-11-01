import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/technician.dart';
import 'package:flutter/material.dart';
import 'technician_edit_screen.dart';
import '../reports/technician_pdf_preview_screen.dart';

class TechniciansListScreen extends StatefulWidget {
  const TechniciansListScreen({super.key});

  @override
  State<TechniciansListScreen> createState() => _TechniciansListScreenState();
}

class _TechniciansListScreenState extends State<TechniciansListScreen> {
  List<Technician> _allTechnicians = [];
  List<Technician> _filteredTechnicians = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  final Set<Technician> _selectedTechnicians = {};

  @override
  void initState() {
    super.initState();
    _fetchTechnicians();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTechnicians() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(ApiService.tecnicos));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('tecnicos') && body['tecnicos'] != null) {
          final List<dynamic> data = body['tecnicos'];
          _allTechnicians = data.map((json) => Technician.fromJson(json)).toList();
          _filteredTechnicians = List.from(_allTechnicians);
        } else {
          _allTechnicians = [];
          _filteredTechnicians = [];
        }
      } else {
        throw Exception('Failed to load technicians');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching technicians: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTechnicians = _allTechnicians.where((tech) {
        return tech.fullName.toLowerCase().contains(query);
      }).toList();
      _selectedTechnicians.removeWhere((item) => !_filteredTechnicians.contains(item));
    });
  }

  Future<void> _deleteTechnician(int id) async {
    final response = await http.delete(Uri.parse('${ApiService.tecnicos}/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      _fetchTechnicians();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete technician.')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Technician technician, AppStrings strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text('Are you sure you want to delete ${technician.fullName}?'),
          actions: <Widget>[
            TextButton(child: Text(strings.cancel), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTechnician(technician.id);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(Technician? technician) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TechnicianEditScreen(technician: technician)),
    );
    if (result == true) {
      _fetchTechnicians();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.technicians)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: strings.searchTechnicians,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                      child: DataTable(
                        onSelectAll: (selected) => setState(() => selected! ? _selectedTechnicians.addAll(_filteredTechnicians) : _selectedTechnicians.clear()),
                        columns: [
                          DataColumn(label: Text(strings.name)),
                          DataColumn(label: Text(strings.specialty)),
                          DataColumn(label: Text(strings.actions)),
                        ],
                        rows: _filteredTechnicians.map((tech) {
                          final isSelected = _selectedTechnicians.contains(tech);
                          return DataRow(
                            selected: isSelected,
                            onSelectChanged: (selected) => setState(() => isSelected ? _selectedTechnicians.remove(tech) : _selectedTechnicians.add(tech)),
                            cells: [
                              DataCell(Text(tech.fullName)),
                              DataCell(Text(tech.especialidad)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEditScreen(tech)),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(context, tech, strings)),
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
              ],
            ),
      bottomNavigationBar: _selectedTechnicians.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicianPdfPreviewScreen(technicians: _selectedTechnicians.toList()))),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text('Generate PDF for ${_selectedTechnicians.length} items'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),
                ),
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(null),
        tooltip: strings.addTechnician,
        child: const Icon(Icons.add),
      ),
    );
  }
}