import 'dart:typed_data';
import '../../constants/app_strings.dart';
import '../../models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({super.key, required this.equipments});

  final List<Equipment> equipments;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reportPreview),
      ),
      body: Builder(
        builder: (context) => PdfPreview(
          build: (format) => _generatePdf(format, equipments, strings),
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<Equipment> equipments, AppStrings strings) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        header: (context) => pw.Text(strings.datasheetReport, style: pw.Theme.of(context).header2),
        build: (context) => [
          _buildEquipmentTable(context, equipments, strings),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildEquipmentTable(pw.Context context, List<Equipment> equipments, AppStrings strings) {
    final headers = [
      strings.assetCode,
      strings.name,
      strings.type,
      strings.brand,
      strings.organizationManagement,
      strings.characteristics,
      strings.status,
      strings.lastMaintenanceShort,
      strings.nextMaintenanceShort,
    ];

    final data = equipments.map((equipment) {
      return [
        equipment.codigo,
        equipment.nombre,
        equipment.tipo,
        equipment.marca,
        equipment.organization?.nombre ?? strings.notAvailable,
        equipment.characteristics,
        equipment.estado,
        equipment.ultimoMantenimiento != null ? DateFormat('dd-MM-yyyy').format(equipment.ultimoMantenimiento!) : '',
        equipment.proximoMantenimiento != null ? DateFormat('dd-MM-yyyy').format(equipment.proximoMantenimiento!) : '',
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
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerLeft,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
        8: pw.Alignment.center,
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }
}
