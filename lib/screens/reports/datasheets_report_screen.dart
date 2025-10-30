import 'package:endetech/constants/app_strings.dart';
import 'package:endetech/screens/reports/report_preview_screen.dart';
import 'package:flutter/material.dart';

class DatasheetsReportScreen extends StatefulWidget {
  const DatasheetsReportScreen({super.key});

  @override
  State<DatasheetsReportScreen> createState() => _DatasheetsReportScreenState();
}

class _DatasheetsReportScreenState extends State<DatasheetsReportScreen> {
  String? _selectedUnit;
  String? _selectedType;
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;

  // Dummy data for filters
  final List<String> _units = ['Unit A', 'Unit B', 'Unit C'];
  final List<String> _types = ['Laptop', 'Desktop', 'Server'];
  final List<String> _statuses = ['Active', 'Inactive', 'In Repair'];

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.datasheetReport),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filter Report Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              hint: const Text('All Units'),
              onChanged: (value) => setState(() => _selectedUnit = value),
              items: _units.map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              hint: const Text('All Types'),
              onChanged: (value) => setState(() => _selectedType = value),
              items: _types.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              decoration: const InputDecoration(
                labelText: AppStrings.type,
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              hint: const Text(AppStrings.allStatuses),
              onChanged: (value) => setState(() => _selectedStatus = value),
              items: _statuses.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              decoration: const InputDecoration(
                labelText: AppStrings.status,
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text(
                _selectedDateRange == null
                    ? 'Not set'
                    : '${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateRange(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportPreviewScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(AppStrings.generateReport),
            ),
          ],
        ),
      ),
    );
  }
}
