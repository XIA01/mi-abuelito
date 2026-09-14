import 'package:flutter/material.dart';
import '../models/vital_sign.dart';

/// Fila scrolleable de alta legibilidad médica para la planilla del doctor.
/// Muestra fecha, hora, franja horaria, tipo/valor y badge de severidad clínica.
class DoctorTableRow extends StatelessWidget {
  final VitalSign registro;
  final bool isEven;
  final VoidCallback? onTap;

  const DoctorTableRow({
    super.key,
    required this.registro,
    this.isEven = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severity = registro.severity;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: severity == ClinicalSeverity.crisis
              ? Colors.red.shade300
              : severity == ClinicalSeverity.alerta
                  ? Colors.orange.shade200
                  : Colors.grey.shade200,
          width: severity == ClinicalSeverity.crisis ? 1.5 : 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
          // ── Fecha y Hora ────────────────────────────────────────────────
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registro.fechaFormateada,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  registro.horaFormateada,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Franja horaria ───────────────────────────────────────────────
          SizedBox(
            width: 28,
            child: Tooltip(
              message: registro.timeSlot.label,
              child: Icon(
                registro.timeSlot.icon,
                color: registro.timeSlot.color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Tipo e ícono ─────────────────────────────────────────────────
          SizedBox(
            width: 26,
            child: Text(
              _tipoEmoji(registro.type),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 6),

          // ── Valor principal ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registro.valorFormateado,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _colorPorSeveridad(severity),
                  ),
                ),
                if (registro.type == VitalType.glucosa &&
                    registro.glucosaMomento != null)
                  Text(
                    _labelMomento(registro.glucosaMomento!),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                if (registro.type == VitalType.presion)
                  Text(
                    registro.presionCategoriaTexto,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                if (registro.notas != null && registro.notas!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '📝 ${registro.notas}',
                      style: TextStyle(
                          fontSize: 10, color: Colors.blueGrey.shade400,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Badge de severidad ────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: severity.bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: severity.textColor.withOpacity(0.4), width: 0.8),
                ),
                child: Text(
                  severity.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: severity.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                registro.familiarNombre,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),
);
}

  String _tipoEmoji(VitalType type) {
    switch (type) {
      case VitalType.glucosa:
        return '🩸';
      case VitalType.orina:
        return '💧';
      case VitalType.presion:
        return '💓';
    }
  }

  Color _colorPorSeveridad(ClinicalSeverity s) {
    switch (s) {
      case ClinicalSeverity.normal:
        return const Color(0xFF2E7D32);
      case ClinicalSeverity.precaucion:
        return const Color(0xFFF57F17);
      case ClinicalSeverity.alerta:
        return const Color(0xFFC62828);
      case ClinicalSeverity.crisis:
        return const Color(0xFFB71C1C);
    }
  }

  String _labelMomento(String m) {
    const map = {
      'ayunas': 'En ayunas',
      'antes_comer': 'Antes de comer',
      'despues_comer': '2h después de comer',
      'noche': 'Noche',
    };
    return map[m] ?? m;
  }
}
