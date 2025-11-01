import 'dart:convert';
import '../../api/api_service.dart';
import '../../models/organization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_strings.dart';
import 'organization_edit_screen.dart';

class OrganizationsListScreen extends StatefulWidget {
  const OrganizationsListScreen({super.key});

  @override
  State<OrganizationsListScreen> createState() => _OrganizationsListScreenState();
}

class _OrganizationsListScreenState extends State<OrganizationsListScreen> {
  List<Organization> _allOrganizations = [];
  List<Organization> _filteredOrganizations = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrganizations();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(ApiService.organizations));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body.containsKey('organizations') && body['organizations'] != null) {
          final List<dynamic> data = body['organizations'];
          _allOrganizations = data.map((json) => Organization.fromJson(json)).toList();
          _filteredOrganizations = List.from(_allOrganizations);
        } else {
          _allOrganizations = [];
          _filteredOrganizations = [];
        }
      } else {
        throw Exception('Failed to load organizations');
      }
    } catch (e) {
      // Handle error, e.g., show a snackbar
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrganizations = _allOrganizations.where((org) {
        return org.nombre.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteOrganization(int id) async {
    final response = await http.delete(Uri.parse('${ApiService.organizations}/$id'));
    if (response.statusCode == 200 || response.statusCode == 204) {
      _fetchOrganizations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete organization.')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Organization organization, AppStrings strings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.delete),
          content: Text(strings.deleteOrganizationConfirmation),
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

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Organizations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
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
                        columns: [
                          const DataColumn(label: Text('Nombre')),
                          const DataColumn(label: Text('Description')),
                          DataColumn(label: Text(strings.actions)),
                        ],
                        rows: _filteredOrganizations.map((org) {
                          return DataRow(
                            cells: [
                              DataCell(Text(org.nombre)),
                              DataCell(Text(org.description)),
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
