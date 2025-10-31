import 'dart:convert';
import '../../api/api_service.dart';
import '../../models/organization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrganizationsListScreen extends StatefulWidget {
  const OrganizationsListScreen({super.key});

  @override
  State<OrganizationsListScreen> createState() => _OrganizationsListScreenState();
}

class _OrganizationsListScreenState extends State<OrganizationsListScreen> {
  late Future<List<Organization>> _organizationsFuture;

  @override
  void initState() {
    super.initState();
    _organizationsFuture = _fetchOrganizations();
  }

  Future<List<Organization>> _fetchOrganizations() async {
    final response = await http.get(Uri.parse(ApiService.organizations));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      // The API response has the list under the 'organizations' key
      if (body.containsKey('organizations') && body['organizations'] != null) {
        final List<dynamic> data = body['organizations'];
        return data.map((json) => Organization.fromJson(json)).toList();
      } else {
        return []; // Return an empty list if 'organizations' is null or not present
      }
    } else {
      throw Exception('Failed to load organizations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
      ),
      body: FutureBuilder<List<Organization>>(
        future: _organizationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No organizations found.'));
          } else {
            final organizations = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Updated At')),
                  ],
                  rows: organizations.map((org) {
                    return DataRow(
                      cells: [
                        DataCell(Text(org.nombre)),
                        DataCell(Text(org.description)),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(org.createdAt))),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(org.updatedAt))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
