import 'dart:typed_data';
import 'package:endetech/constants/app_strings.dart';

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
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reportPreview),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, maintenances, strings),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<Maintenance> maintenances, AppStrings strings) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        header: (context) => pw.Text(strings.datasheetReport, style: pw.Theme.of(context).header2),
        build: (context) => [
          _buildMaintenanceTable(context, maintenances, strings),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildMaintenanceTable(pw.Context context, List<Maintenance> maintenances, AppStrings strings) {
    final headers = [strings.equipment, strings.technician, strings.date, strings.status];

    final data = maintenances.map((maint) {
      return [
        maint.equipo.codigo,
        maint.tecnico.fullName,
        DateFormat('dd/MM/yyyy').format(maint.fechaProgramada),
        maint.estado,
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
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }
}
