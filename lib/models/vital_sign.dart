import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum VitalType { glucosa, orina, presion }

enum TimeSlot {
  manana('Mañana (Ayunas)', Icons.wb_sunny_outlined, Color(0xFFE65100)),
  tarde('Tarde (Postprandial)', Icons.wb_twilight_outlined, Color(0xFF1565C0)),
  noche('Noche (Antes de dormir)', Icons.nightlight_round_outlined, Color(0xFF4A148C));

  final String label;
  final IconData icon;
  final Color color;
  const TimeSlot(this.label, this.icon, this.color);

  static TimeSlot fromDateTime(DateTime dt) {
    final hour = dt.hour;
    if (hour >= 5 && hour < 12) return TimeSlot.manana;
    if (hour >= 12 && hour < 19) return TimeSlot.tarde;
    return TimeSlot.noche;
  }
}

enum ClinicalSeverity {
  normal('Normal', Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  precaucion('Elevado', Color(0xFFF57F17), Color(0xFFFFFDE7)),
  alerta('Alerta', Color(0xFFC62828), Color(0xFFFFEBEE)),
  crisis('Crítico', Color(0xFFB71C1C), Color(0xFFFFCDD2));

  final String label;
  final Color textColor;
  final Color bgColor;
  const ClinicalSeverity(this.label, this.textColor, this.bgColor);
}

class VitalSign {
  final String id;
  final String abueloId;
  final VitalType type;
  final DateTime timestamp;
  final TimeSlot timeSlot;
  final String familiarNombre;
  final String? parentesco;
  final String? notas;

  // Glucosa
  final double? glucosaValor; // en mg/dL
  final String? glucosaMomento; // 'ayunas', 'antes_comer', 'despues_comer', 'noche'

  // Orina
  final int? orinaCc; // en cc / ml
  final bool esPanal;
  final String? orinaAspecto; // 'clara', 'oscura', 'sedimentos'

  // Presión Arterial
  final int? sistolica; // PAS (mmHg)
  final int? diastolica; // PAD (mmHg)
  final int? pulso; // bpm

  VitalSign({
    required this.id,
    required this.abueloId,
    required this.type,
    required this.timestamp,
    required this.timeSlot,
    required this.familiarNombre,
    this.parentesco,
    this.notas,
    this.glucosaValor,
    this.glucosaMomento,
    this.orinaCc,
    this.esPanal = false,
    this.orinaAspecto,
    this.sistolica,
    this.diastolica,
    this.pulso,
  });

  // Cálculo clínico de severidad para la glucosa (ADA)
  ClinicalSeverity get glucosaSeverity {
    if (glucosaValor == null) return ClinicalSeverity.normal;
    final v = glucosaValor!;
    if (v < 70) return ClinicalSeverity.crisis; // Hipoglucemia
    if (v <= 130) return ClinicalSeverity.normal;
    if (v <= 180) return ClinicalSeverity.precaucion;
    if (v <= 250) return ClinicalSeverity.alerta;
    return ClinicalSeverity.crisis;
  }

  // Clasificación médica de la Presión Arterial (AHA / ACC)
  ClinicalSeverity get presionSeverity {
    if (sistolica == null || diastolica == null) return ClinicalSeverity.normal;
    final s = sistolica!;
    final d = diastolica!;

    if (s > 180 || d > 120) return ClinicalSeverity.crisis;
    if (s >= 140 || d >= 90) return ClinicalSeverity.alerta; // HTA Grado 2
    if (s >= 130 || d >= 80) return ClinicalSeverity.precaucion; // HTA Grado 1
    if (s >= 120 && d < 80) return ClinicalSeverity.precaucion; // Elevada
    return ClinicalSeverity.normal;
  }

  String get presionCategoriaTexto {
    if (sistolica == null || diastolica == null) return 'N/A';
    final s = sistolica!;
    final d = diastolica!;
    if (s > 180 || d > 120) return 'Crisis Hipertensiva';
    if (s >= 140 || d >= 90) return 'HTA Grado 2';
    if (s >= 130 || d >= 80) return 'HTA Grado 1';
    if (s >= 120 && d < 80) return 'Presión Elevada';
    return 'Presión Normal';
  }

  // Severidad general del registro
  ClinicalSeverity get severity {
    switch (type) {
      case VitalType.glucosa:
        return glucosaSeverity;
      case VitalType.presion:
        return presionSeverity;
      case VitalType.orina:
        if (orinaCc != null && orinaCc! < 100) return ClinicalSeverity.precaucion;
        return ClinicalSeverity.normal;
    }
  }

  // Texto resumido formateado para notificaciones y tarjetas
  String get valorFormateado {
    switch (type) {
      case VitalType.glucosa:
        return '${glucosaValor?.toStringAsFixed(0) ?? "--"} mg/dL';
      case VitalType.orina:
        if (esPanal) return 'Pañal cargado';
        return '${orinaCc ?? "--"} cc';
      case VitalType.presion:
        final pulsoStr = pulso != null ? ' (${pulso} lpm)' : '';
        return '$sistolica / $diastolica mmHg$pulsoStr';
    }
  }

  String get resumenNotificacion {
    final hora = DateFormat('HH:mm').format(timestamp);
    switch (type) {
      case VitalType.glucosa:
        return '$familiarNombre agregó a las $hora: ${glucosaValor?.toStringAsFixed(0)} mg/dL de azúcar ($glucosaMomento)';
      case VitalType.orina:
        final cant = esPanal ? 'un pañal' : '$orinaCc cc de orina';
        return '$familiarNombre registró a las $hora: $cant';
      case VitalType.presion:
        return '$familiarNombre midió a las $hora: $sistolica/$diastolica de presión';
    }
  }

  String get fechaFormateada => DateFormat('dd/MM/yyyy').format(timestamp);
  String get horaFormateada => DateFormat('HH:mm').format(timestamp);
  String get fechaYHoraFormateada => DateFormat('dd MMM - HH:mm', 'es').format(timestamp);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'abueloId': abueloId,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'timeSlot': timeSlot.name,
      'familiarNombre': familiarNombre,
      'parentesco': parentesco,
      'notas': notas,
      'glucosaValor': glucosaValor,
      'glucosaMomento': glucosaMomento,
      'orinaCc': orinaCc,
      'esPanal': esPanal,
      'orinaAspecto': orinaAspecto,
      'sistolica': sistolica,
      'diastolica': diastolica,
      'pulso': pulso,
    };
  }

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      id: json['id'] as String,
      abueloId: json['abueloId'] as String,
      type: VitalType.values.byName(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      timeSlot: TimeSlot.values.byName(json['timeSlot'] as String),
      familiarNombre: json['familiarNombre'] as String,
      parentesco: json['parentesco'] as String?,
      notas: json['notas'] as String?,
      glucosaValor: (json['glucosaValor'] as num?)?.toDouble(),
      glucosaMomento: json['glucosaMomento'] as String?,
      orinaCc: json['orinaCc'] as int?,
      esPanal: json['esPanal'] as bool? ?? false,
      orinaAspecto: json['orinaAspecto'] as String?,
      sistolica: json['sistolica'] as int?,
      diastolica: json['diastolica'] as int?,
      pulso: json['pulso'] as int?,
    );
  }
}
