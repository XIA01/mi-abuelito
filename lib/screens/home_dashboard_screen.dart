import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/patient_provider.dart';
import '../models/vital_sign.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/flag_counter_widget.dart';
import 'log_vital_screen.dart';
import 'doctor_sheet_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  void _mostrarDialogoCodigo(BuildContext context, String codigo, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Text('🔑 ', style: TextStyle(fontSize: 22)),
            Expanded(child: Text('Código de $nombre')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cualquier familiar (tu sobrina, hijos, etc.) puede usar este código para conectarse y registrar:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                ),
                child: Text(
                  codigo,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Solo ingresan en "Tengo un código" y listo.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copiar código'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: codigo));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Código $codigo copiado al portapapeles'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSalir(BuildContext context, PatientProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Salir de este dispositivo'),
          ],
        ),
        content: const Text(
          '¿Deseás cerrar tu perfil en este celular?\n\n'
          '• Volverás a la pantalla principal.\n'
          '• Los datos del abuelo se mantienen guardados y tus familiares con el código podrán seguir usándolo.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.salirDeEsteDispositivo();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, PatientProvider provider) {
    final nombre = provider.perfil?.nombre ?? 'el abuelo';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text('¿Eliminar todos los datos?')),
          ],
        ),
        content: Text(
          '⚠️ Esta acción borrará la ficha de $nombre y todo el historial de glucosa, orina y presión en este dispositivo.\n\n'
          'Esta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.eliminarAbueloYDatos();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Perfil e historial eliminados'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoDonar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('☕ '),
            Expanded(child: Text('Apoyar el proyecto')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi Abuelito es un proyecto gratuito y familiar hecho para ayudar a cuidar con cariño la salud de nuestros abuelos.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            const Text(
              'Si la app te sirve y querés colaborar con los costos de mantenimiento o invitar un cafecito/tecito, podés transferir por Mercado Pago o banco al Alias:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALIAS MERCADO PAGO / BANCO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const SelectableText(
                        'b1.66er',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    tooltip: 'Copiar Alias',
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'b1.66er'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('✅ ¡Alias b1.66er copiado al portapapeles!'),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '¡Muchas gracias por tu apoyo! ❤️',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          final perfil = provider.perfil;
          if (perfil == null) return const SizedBox();

          return CustomScrollView(
            slivers: [
              // ── AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.blue.shade800,
                flexibleSpace: FlexibleSpaceBar(
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👴 ${perfil.nombre}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: ${perfil.id}  •  ${provider.familiarNombre}',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.medical_services_outlined,
                        color: Colors.white),
                    tooltip: 'Planilla Médica',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DoctorSheetScreen()),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    tooltip: 'Opciones de cuenta',
                    onSelected: (val) {
                      if (val == 'codigo') {
                        _mostrarDialogoCodigo(context, perfil.id, perfil.nombre);
                      } else if (val == 'donar') {
                        _mostrarDialogoDonar(context);
                      } else if (val == 'salir') {
                        _mostrarDialogoSalir(context, provider);
                      } else if (val == 'eliminar') {
                        _mostrarDialogoEliminar(context, provider);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'codigo',
                        child: Row(
                          children: [
                            Icon(Icons.share_outlined, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Código para la familia'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'donar',
                        child: Row(
                          children: [
                            Text('☕', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text('Apoyar el proyecto (Café)'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'salir',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.orange),
                            SizedBox(width: 10),
                            Text('Salir de este dispositivo'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever_outlined, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Eliminar abuelo y datos',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Resumen del Día ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoy, ${DateFormat('EEEE d \'de\' MMMM', 'es').format(DateTime.now())}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _LastReadingCard(
                              emoji: '🩸',
                              label: 'Azúcar',
                              registro: provider.ultimaGlucosa,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _LastReadingCard(
                              emoji: '💓',
                              label: 'Presión',
                              registro: provider.ultimaPresion,
                              color: Colors.pink.shade400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _LastReadingCard(
                              emoji: '💧',
                              label: 'Orina',
                              registro: provider.ultimaOrina,
                              color: Colors.blue.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Botones de Carga Rápida ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registrar ahora',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickLogButton(
                              emoji: '🩸',
                              label: 'Azúcar',
                              color: Colors.red.shade600,
                              onTap: () => _abrirLog(
                                  context, VitalType.glucosa),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickLogButton(
                              emoji: '💓',
                              label: 'Presión',
                              color: Colors.pink.shade600,
                              onTap: () => _abrirLog(
                                  context, VitalType.presion),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickLogButton(
                              emoji: '💧',
                              label: 'Orina',
                              color: Colors.blue.shade600,
                              onTap: () => _abrirLog(
                                  context, VitalType.orina),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Feed Familiar ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Últimos registros',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const DoctorSheetScreen()),
                        ),
                        child: const Text('Ver todo →'),
                      ),
                    ],
                  ),
                ),
              ),

              if (provider.todosRegistros.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Text('📋', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(
                            'Todavía no hay registros.\n¡Empezá anotando el primero!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) {
                      final reg = provider.todosRegistros[idx];
                      return _FeedTile(registro: reg);
                    },
                    childCount:
                        provider.todosRegistros.length.clamp(0, 20),
                  ),
                ),

               // ── Tarjeta Apoyar / Cafecito ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('☕', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '¿Te resulta útil la app?',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Podés apoyar el proyecto invitando un café al Alias b1.66er.',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () => _mostrarDialogoDonar(context),
                          child: const Text('Apoyar',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Banner AdMob ─────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: AdBannerWidget()),
                ),
              ),

              // ── Flag Counter Footer ──────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 28),
                  child: FlagCounterWidget(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _abrirLog(BuildContext context, VitalType tipo) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LogVitalScreen(tipo: tipo)),
    );
  }
}

// ─── Tarjeta de último valor ──────────────────────────────────────────────────
class _LastReadingCard extends StatelessWidget {
  final String emoji;
  final String label;
  final VitalSign? registro;
  final Color color;

  const _LastReadingCard({
    required this.emoji,
    required this.label,
    required this.registro,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final severity = registro?.severity;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
        border: Border.all(
          color: severity != null
              ? severity.textColor.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            registro != null ? registro!.valorFormateado : '—',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: severity?.textColor ?? Colors.grey.shade400,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          if (registro != null)
            Text(
              registro!.horaFormateada,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }
}

// ─── Botón de carga rápida ────────────────────────────────────────────────────
class _QuickLogButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tile del feed familiar ───────────────────────────────────────────────────
class _FeedTile extends StatelessWidget {
  final VitalSign registro;

  const _FeedTile({required this.registro});

  @override
  Widget build(BuildContext context) {
    final severity = registro.severity;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: severity.textColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(_emoji(registro.type), style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registro.valorFormateado,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: severity.textColor,
                  ),
                ),
                Text(
                  '${registro.familiarNombre} · ${registro.fechaYHoraFormateada}',
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severity.bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              severity.label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: severity.textColor),
            ),
          ),
        ],
      ),
    );
  }

  String _emoji(VitalType t) {
    switch (t) {
      case VitalType.glucosa:
        return '🩸';
      case VitalType.orina:
        return '💧';
      case VitalType.presion:
        return '💓';
    }
  }
}
