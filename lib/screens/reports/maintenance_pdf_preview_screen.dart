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
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<Maintenance> maintenances, AppStrings strings) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        header: (context) => pw.Text(strings.maintenanceReport, style: pw.Theme.of(context).header2),
        build: (context) => [
          _buildMaintenanceTable(context, maintenances, strings),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildMaintenanceTable(pw.Context context, List<Maintenance> maintenances, AppStrings strings) {
    final headers = [
      strings.date,
      strings.organization,
      strings.equipment,
      strings.technician,
      strings.characteristics,
      strings.tasks,
      strings.observations,
      strings.status,
    ];

    final data = maintenances.map((maint) {
      final characteristics = [
        if (maint.equipo?.sistemaOperativo != null && maint.equipo!.sistemaOperativo!.isNotEmpty) 'SO: ${maint.equipo!.sistemaOperativo}',
        if (maint.equipo?.procesador != null && maint.equipo!.procesador!.isNotEmpty) 'CPU: ${maint.equipo!.procesador}',
        if (maint.equipo?.memoriaRam != null && maint.equipo!.memoriaRam!.isNotEmpty) 'RAM: ${maint.equipo!.memoriaRam}',
        if (maint.equipo?.almacenamiento != null && maint.equipo!.almacenamiento!.isNotEmpty) 'Almacenamiento: ${maint.equipo!.almacenamiento}',
      ].join('\n');

      final tasks = maint.tareas.isNotEmpty
          ? maint.tareas.map((t) => t.nombre).join(', ')
          : strings.none;

      return [
        DateFormat('dd/MM/yyyy').format(maint.fechaProgramada),
        maint.equipo?.organization?.nombre ?? strings.notAvailable,
        maint.equipo?.nombre ?? strings.notAvailable,
        maint.tecnico?.fullName ?? strings.unassigned,
        characteristics.isNotEmpty ? characteristics : strings.notAvailable,
        tasks,
        maint.observaciones ?? strings.none,
        maint.estado,
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerLeft,
        6: pw.Alignment.centerLeft,
        7: pw.Alignment.center,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(2.5),
        3: const pw.FlexColumnWidth(2.5),
        4: const pw.FlexColumnWidth(3.5),
        5: const pw.FlexColumnWidth(3.5),
        6: const pw.FlexColumnWidth(3.5),
        7: const pw.FlexColumnWidth(2),
      },
      cellPadding: const pw.EdgeInsets.all(3),
    );
  }
}
