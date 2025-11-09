import '../../api_service.dart';
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
  final ApiService _apiService = ApiService();
  
  List<Technician> _allTechnicians = [];
  List<Technician> _filteredTechnicians = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  final _searchController = TextEditingController();
  final Set<Technician> _selectedTechnicians = {};

  bool _didFetchData = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchData) {
      _fetchTechnicians();
      _didFetchData = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTechnicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.getTecnicos(context);

    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data']['tecnicos'];
        setState(() {
          _allTechnicians = data.map((json) => Technician.fromJson(json)).toList();
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
      _filteredTechnicians = _allTechnicians.where((tech) {
        return tech.fullName.toLowerCase().contains(query) || tech.especialidad.toLowerCase().contains(query);
      }).toList();
      _selectedTechnicians.removeWhere((item) => !_filteredTechnicians.contains(item));
    });
  }

  Future<void> _deleteTechnician(int id) async {
    final result = await _apiService.deleteTecnico(context, id);
    if (mounted) {
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['success'] 
            ? (result['data']?['message'] ?? strings.technicianDeleted) 
            : result['message'] ?? strings.unexpectedErrorOccurred)),
      );
      if (result['success']) {
        _fetchTechnicians();
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Technician technician, AppStrings strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text(strings.deleteTechnicianConfirmation(technician.fullName)),
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
  
  Widget _buildErrorView() {
    final strings = AppStrings.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchTechnicians, child: Text(strings.retry)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.technicians)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
            ? _buildErrorView()
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
                  child: _filteredTechnicians.isEmpty
                      ? Center(child: Text(strings.noResultsFound))
                      : SingleChildScrollView(
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
                  label: Text(strings.generatePdfForN(_selectedTechnicians.length, strings.technicians.toLowerCase())),
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
