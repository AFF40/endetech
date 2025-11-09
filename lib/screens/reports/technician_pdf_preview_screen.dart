import 'dart:typed_data';
import '../../constants/app_strings.dart';
import '../../models/technician.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TechnicianPdfPreviewScreen extends StatelessWidget {
  const TechnicianPdfPreviewScreen({super.key, required this.technicians});

  final List<Technician> technicians;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.technicianReportPreviewTitle),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, technicians, strings),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<Technician> technicians, AppStrings strings) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        header: (context) => pw.Text(strings.consolidatedTechnicianReport, style: pw.Theme.of(context).header2),
        build: (context) => [
          _buildTechnicianTable(context, technicians, strings),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildTechnicianTable(pw.Context context, List<Technician> technicians, AppStrings strings) {
    final headers = [strings.name, strings.specialty];

    final data = technicians.map((tech) {
      return [tech.fullName, tech.especialidad];
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
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }
}
