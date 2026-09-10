import 'package:flutter/material.dart';

/// El Flag Counter real está en web/index.html como elemento HTML nativo
/// para que FlagCounter registre la IP real del visitante (no la del proxy).
/// Este widget solo ocupa el espacio reservado en el scroll para no tapar el contador.
class FlagCounterWidget extends StatelessWidget {
  const FlagCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Espacio para que el contenido no quede tapado por el contador flotante del HTML
    return const SizedBox(height: 60);
  }
}

