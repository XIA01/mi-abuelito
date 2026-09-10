import 'package:flutter/material.dart';
import '../models/vital_sign.dart';

/// Cabecera fija de promedios clínicos para el Modo Planilla Médica
class DoctorSummaryHeader extends StatelessWidget {
  final Map<String, dynamic> resumen;
  final String periodoLabel;

  const DoctorSummaryHeader({
    super.key,
    required this.resumen,
    required this.periodoLabel,
  });

  @override
  Widget build(BuildContext context) {
    final glucosa = resumen['glucosaPromedio'] as double?;
    final pas = resumen['pasPromedio'] as double?;
    final pad = resumen['padPromedio'] as double?;
    final orina = resumen['orinaTotal'] as int?;
    final total = resumen['totalRegistros'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services_outlined,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'RESUMEN MÉDICO · $periodoLabel',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total registros',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  emoji: '🩸',
                  label: 'Glucosa Prom.',
                  valor: glucosa != null
                      ? '${glucosa.toStringAsFixed(0)} mg/dL'
                      : 'Sin datos',
                  color: _glucosaColor(glucosa),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  emoji: '💓',
                  label: 'Presión Prom.',
                  valor: (pas != null && pad != null)
                      ? '${pas.toStringAsFixed(0)}/${pad.toStringAsFixed(0)}'
                      : 'Sin datos',
                  color: _presionColor(pas),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  emoji: '💧',
                  label: 'Orina Total',
                  valor: orina != null ? '$orina cc' : 'Sin datos',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _glucosaColor(double? v) {
    if (v == null) return Colors.white;
    if (v < 70 || v > 220) return Colors.red.shade200;
    if (v > 130) return Colors.orange.shade200;
    return Colors.green.shade200;
  }

  Color _presionColor(double? v) {
    if (v == null) return Colors.white;
    if (v > 140) return Colors.red.shade200;
    if (v > 120) return Colors.orange.shade200;
    return Colors.green.shade200;
  }
}

class _MetricCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String valor;
  final Color color;

  const _MetricCard({
    required this.emoji,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
