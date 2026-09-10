import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/vital_sign.dart';
import '../models/patient_profile.dart';

class PdfReportService {
  /// Genera y abre el diálogo de impresión/descarga del reporte médico
  Future<void> generarYCompartirReporte({
    required PatientProfile perfil,
    required List<VitalSign> registros,
    required String periodoLabel,
    required BuildContext context,
  }) async {
    final pdfBytes = await _buildPdf(perfil, registros, periodoLabel);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Reporte_${perfil.nombre}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf',
    );
  }

  Future<Uint8List> _buildPdf(
    PatientProfile perfil,
    List<VitalSign> registros,
    String periodoLabel,
  ) async {
    final pdf = pw.Document();
    final fechaGeneracion = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Calcular promedios
    final glucosas = registros
        .where((r) => r.type == VitalType.glucosa && r.glucosaValor != null)
        .map((r) => r.glucosaValor!)
        .toList();
    final presiones = registros
        .where((r) => r.type == VitalType.presion && r.sistolica != null)
        .toList();
    final orinas = registros
        .where((r) => r.type == VitalType.orina && r.orinaCc != null)
        .map((r) => r.orinaCc!)
        .toList();

    final glucosaPromedio = glucosas.isNotEmpty
        ? glucosas.reduce((a, b) => a + b) / glucosas.length
        : null;
    final presionSisPromedio = presiones.isNotEmpty
        ? presiones.map((r) => r.sistolica!).reduce((a, b) => a + b) / presiones.length
        : null;
    final presionDiaPromedio = presiones.isNotEmpty
        ? presiones.map((r) => r.diastolica!).reduce((a, b) => a + b) / presiones.length
        : null;
    final orinaTotal24h = orinas.isNotEmpty
        ? orinas.reduce((a, b) => a + b)
        : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        header: (context) => _buildHeader(perfil, fechaGeneracion, periodoLabel),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildResumenEjecutivo(
            glucosaPromedio,
            presionSisPromedio,
            presionDiaPromedio,
            orinaTotal24h,
            registros.length,
          ),
          pw.SizedBox(height: 16),
          _buildTablaRegistros(registros),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    PatientProfile perfil,
    String fechaGen,
    String periodo,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '📋 REPORTE MÉDICO',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  '${perfil.nombre}  •  ${perfil.edad} años  •  ID: ${perfil.id}',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Período: $periodo',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Text('Generado: $fechaGen',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
              ],
            ),
          ],
        ),
        pw.Divider(color: PdfColors.blue800, thickness: 1.5),
        pw.SizedBox(height: 4),
      ],
    );
  }

  pw.Widget _buildResumenEjecutivo(
    double? glucosa,
    double? pas,
    double? pad,
    int? orinaTotal,
    int totalRegistros,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMEN EJECUTIVO',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _metricaCell('🩸 Glucosa Promedio',
                  glucosa != null ? '${glucosa.toStringAsFixed(0)} mg/dL' : 'Sin datos'),
              _metricaCell('💓 Presión Promedio',
                  (pas != null && pad != null)
                      ? '${pas.toStringAsFixed(0)}/${pad.toStringAsFixed(0)} mmHg'
                      : 'Sin datos'),
              _metricaCell('💧 Orina Total (período)',
                  orinaTotal != null ? '$orinaTotal cc' : 'Sin datos'),
              _metricaCell('📊 Total Registros', '$totalRegistros'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _metricaCell(String label, String valor) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(valor,
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
      ],
    );
  }

  pw.Widget _buildTablaRegistros(List<VitalSign> registros) {
    const headerStyle = pw.TextStyle(color: PdfColors.white);
    final headerDecoration = pw.BoxDecoration(color: PdfColors.blue800);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.2), // Fecha / Hora
        1: pw.FlexColumnWidth(1.5), // Franja
        2: pw.FlexColumnWidth(2.5), // Tipo / Valor
        3: pw.FlexColumnWidth(1.5), // Estado
        4: pw.FlexColumnWidth(1.8), // Cargó
      },
      children: [
        pw.TableRow(
          decoration: headerDecoration,
          children: [
            _th('Fecha y Hora', headerStyle),
            _th('Franja', headerStyle),
            _th('Tipo / Valor', headerStyle),
            _th('Estado', headerStyle),
            _th('Cargó', headerStyle),
          ],
        ),
        ...registros.asMap().entries.map((entry) {
          final idx = entry.key;
          final r = entry.value;
          final isEven = idx % 2 == 0;
          final bg = isEven ? PdfColors.white : PdfColors.grey50;

          PdfColor statusColor;
          switch (r.severity) {
            case ClinicalSeverity.normal:
              statusColor = PdfColors.green700;
              break;
            case ClinicalSeverity.precaucion:
              statusColor = PdfColors.orange700;
              break;
            case ClinicalSeverity.alerta:
            case ClinicalSeverity.crisis:
              statusColor = PdfColors.red700;
              break;
          }

          String tipoLabel;
          switch (r.type) {
            case VitalType.glucosa:
              tipoLabel = '🩸 ${r.valorFormateado}';
              break;
            case VitalType.orina:
              tipoLabel = '💧 ${r.valorFormateado}';
              break;
            case VitalType.presion:
              tipoLabel = '💓 ${r.valorFormateado}';
              break;
          }

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              _td(r.fechaYHoraFormateada),
              _td(r.timeSlot.label.split(' ').first),
              _td(tipoLabel),
              _tdColor(r.severity.label, statusColor),
              _td(r.familiarNombre),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _th(String text, pw.TextStyle style) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: style.copyWith(fontSize: 9)),
      );

  pw.Widget _td(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
      );

  pw.Widget _tdColor(String text, PdfColor color) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(
          text,
          style: pw.TextStyle(
              fontSize: 9, fontWeight: pw.FontWeight.bold, color: color),
        ),
      );

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Generado con "Mi Abuelito" App',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
        pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
      ],
    );
  }
}
