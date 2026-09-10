import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FlagCounterWidget extends StatelessWidget {
  const FlagCounterWidget({super.key});

  static const String _infoUrl = 'https://info.flagcounter.com/gutV';

  Future<void> _abrirEstadisticas() async {
    final uri = Uri.parse(_infoUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: InkWell(
          onTap: _abrirEstadisticas,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚩', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  'Ver estadísticas de visitas en vivo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

