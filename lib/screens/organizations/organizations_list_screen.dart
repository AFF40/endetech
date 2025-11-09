import '../../api_service.dart';
import '../../constants/app_strings.dart';
import '../../models/organization.dart';
import 'package:flutter/material.dart';
import 'organization_edit_screen.dart';

class OrganizationsListScreen extends StatefulWidget {
  const OrganizationsListScreen({super.key});

  @override
  State<OrganizationsListScreen> createState() => _OrganizationsListScreenState();
}

class _OrganizationsListScreenState extends State<OrganizationsListScreen> {
  final ApiService _apiService = ApiService();

  List<Organization> _allOrganizations = [];
  List<Organization> _filteredOrganizations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final _searchController = TextEditingController();

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
      _fetchOrganizations();
      _didFetchData = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.getOrganizations(context);

    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data']['organizations'];
        setState(() {
          _allOrganizations = data.map((json) => Organization.fromJson(json)).toList();
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
      _filteredOrganizations = _allOrganizations.where((org) {
        return org.nombre.toLowerCase().contains(query) || (org.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _deleteOrganization(int id) async {
    final result = await _apiService.deleteOrganization(context, id);
    if (mounted) {
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['success'] 
            ? (result['data']?['message'] ?? strings.organizationDeleted) 
            : result['message'] ?? strings.unexpectedErrorOccurred)),
      );
      if (result['success']) {
        _fetchOrganizations();
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, Organization organization, AppStrings strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text(strings.confirmDelete('la organización ${organization.nombre}')),
          actions: <Widget>[
            TextButton(child: Text(strings.cancel), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteOrganization(organization.id);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(Organization? organization) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrganizationEditScreen(organization: organization)),
    );
    if (result == true) {
      _fetchOrganizations();
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
          ElevatedButton(onPressed: _fetchOrganizations, child: Text(strings.retry)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.organizationManagement)),
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
                      hintText: strings.searchByName,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredOrganizations.isEmpty
                      ? Center(child: Text(strings.noResultsFound))
                      : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text(strings.name)),
                                DataColumn(label: Text(strings.description)),
                                DataColumn(label: Text(strings.actions)),
                              ],
                              rows: _filteredOrganizations.map((org) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(org.nombre)),
                                    DataCell(Text(org.description ?? '')),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEditScreen(org)),
                                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteConfirmation(context, org, strings)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(null),
        tooltip: strings.addOrganization,
        child: const Icon(Icons.add),
      ),
    );
  }
}
