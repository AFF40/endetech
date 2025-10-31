import 'dart:typed_data';
import '../../models/maintenance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MaintenancePdfPreviewScreen extends StatelessWidget {
  const MaintenancePdfPreviewScreen({super.key, required this.maintenances});

  final List<Maintenance> maintenances;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Report Preview'),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, maintenances),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<Maintenance> maintenances) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        header: (context) => pw.Text('Consolidated Maintenance Report', style: pw.Theme.of(context).header2),
        build: (context) => [
          _buildMaintenanceTable(context, maintenances),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildMaintenanceTable(pw.Context context, List<Maintenance> maintenances) {
    final headers = ['Equipment', 'Technician', 'Type', 'Date', 'Status'];

    final data = maintenances.map((maint) {
      return [
        maint.equipment,
        maint.technician,
        maint.type,
        DateFormat('dd/MM/yyyy').format(maint.date),
        maint.status,
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }
}
