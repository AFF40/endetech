import 'dart:typed_data';
import '../../models/equipment.dart';
import '../../constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key, this.equipments});

  final List<Equipment>? equipments;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reportPreview),
      ),
      body: equipments == null || equipments!.isEmpty
          ? const Center(child: Text('No data to display.'))
          : PdfPreview(
              build: (format) => _generatePdf(format, equipments!),
            ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<Equipment> equipments) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        header: (context) => pw.Text('Consolidated Equipment Report', style: pw.Theme.of(context).header2),
        build: (context) => [
          _buildEquipmentTable(context, equipments),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildEquipmentTable(pw.Context context, List<Equipment> equipments) {
    final headers = [
      'Asset Code',
      'Name',
      'Type',
      'Brand',
      'Org. ID',
      'Characteristics',
      'Status',
      'Last Maint.',
      'Next Maint.'
    ];

    final data = equipments.map((equipment) {
      return [
        equipment.assetCode,
        equipment.name,
        equipment.type,
        equipment.brand,
        equipment.organizationId,
        equipment.characteristics ?? '',
        equipment.status,
        DateFormat('dd/MM/yyyy').format(equipment.lastMaintenance),
        DateFormat('dd/MM/yyyy').format(equipment.nextMaintenance),
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
        5: pw.Alignment.centerLeft,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
        8: pw.Alignment.center,
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }
}
