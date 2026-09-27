import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vital_sign.dart';
import '../providers/patient_provider.dart';
import '../widgets/doctor_summary_header.dart';
import '../widgets/doctor_table_row.dart';
import '../services/pdf_report_service.dart';
import '../services/ad_service.dart';
import 'log_vital_screen.dart';

/// 🩺 Pantalla "Modo Planilla Médica Digital"
/// Diseñada para entregársela al médico en la consulta.
/// Reemplaza el cuaderno o planilla en papel.
class DoctorSheetScreen extends StatefulWidget {
  const DoctorSheetScreen({super.key});

  @override
  State<DoctorSheetScreen> createState() => _DoctorSheetScreenState();
}

class _DoctorSheetScreenState extends State<DoctorSheetScreen> {
  bool _exportando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          final perfil = provider.perfil;
          if (perfil == null) return const SizedBox();

          final registros = provider.registrosFiltrados;
          final resumen = provider.resumenMedico;

          return CustomScrollView(
            slivers: [
              // ── AppBar Médico ────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🩺 Planilla Médica · ${perfil.nombre}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'ID: ${perfil.id}${perfil.edad > 0 ? '  •  ${perfil.edad} años' : ''}',
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
                actions: [
                  // Botón exportar PDF
                  IconButton(
                    icon: _exportando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf_outlined),
                    tooltip: 'Exportar PDF para el médico',
                    onPressed: _exportando ? null : () => _exportarPdf(provider),
                  ),
                ],
              ),

              // ── Cabecera fija con Promedios Clínicos ─────────────────────
              SliverToBoxAdapter(
                child: DoctorSummaryHeader(
                  resumen: resumen,
                  periodoLabel: provider.filtroFechaLabel,
                ),
              ),

              // ── Filtros por Período ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'PERÍODO',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.8),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: FiltroFecha.values.map((f) {
                            final labels = {
                              FiltroFecha.hoy: 'Hoy',
                              FiltroFecha.semana: '7 días',
                              FiltroFecha.quincena: '15 días',
                              FiltroFecha.mes: '30 días',
                              FiltroFecha.todo: 'Todo',
                            };
                            final sel = provider.filtroFecha == f;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(labels[f]!),
                                selected: sel,
                                onSelected: (_) =>
                                    provider.setFiltroFecha(f),
                                selectedColor: Colors.blue.shade600,
                                labelStyle: TextStyle(
                                    color:
                                        sel ? Colors.white : Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Filtros por Franja Horaria
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'FRANJA HORARIA',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.8),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _franjaChip(
                                provider, FiltroFranja.todas, '🕐 Todas'),
                            _franjaChip(
                                provider, FiltroFranja.manana, '☀️ Mañana'),
                            _franjaChip(
                                provider, FiltroFranja.tarde, '🌤️ Tarde'),
                            _franjaChip(
                                provider, FiltroFranja.noche, '🌙 Noche'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Separador y contador ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        '${registros.length} registros',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      Text(
                        'Ordenados del más reciente al más antiguo',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Lista de registros scrolleable ────────────────────────────
              if (registros.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 48),
                    child: Center(
                      child: Column(
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'Sin registros en este período.\nCambiá el filtro para ver más.',
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
                    (context, idx) => DoctorTableRow(
                      registro: registros[idx],
                      isEven: idx % 2 == 0,
                      onTap: () =>
                          _mostrarOpcionesRegistro(context, registros[idx]),
                    ),
                    childCount: registros.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _franjaChip(
      PatientProvider provider, FiltroFranja f, String label) {
    final sel = provider.filtroFranja == f;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) => provider.setFiltroFranja(f),
        selectedColor: Colors.indigo.shade600,
        labelStyle: TextStyle(
          color: sel ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Future<void> _exportarPdf(PatientProvider provider) async {
    setState(() => _exportando = true);
    // Mostrar anuncio Interstitial antes de generar el PDF
    await AdService().mostrarInterstitial();
    if (!mounted) return;
    await PdfReportService().generarYCompartirReporte(
      perfil: provider.perfil!,
      registros: provider.registrosFiltrados,
      periodoLabel: provider.filtroFechaLabel,
      context: context,
    );
    if (mounted) setState(() => _exportando = false);
  }

  void _mostrarOpcionesRegistro(BuildContext context, VitalSign reg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Text(_emojiPorTipo(reg.type),
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reg.valorFormateado,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: reg.severity.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reg.familiarNombre} · ${reg.fechaYHoraFormateada}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: reg.severity.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reg.severity.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: reg.severity.textColor,
                    ),
                  ),
                ),
              ],
            ),
            if (reg.notas != null && reg.notas!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '📝 ${reg.notas}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.blue),
              ),
              title: const Text('Editar medición',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Corregir valor, fecha/hora, notas o momento',
                  style: TextStyle(fontSize: 12)),
              trailing:
                  const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LogVitalScreen(
                      tipo: reg.type,
                      registroAEditar: reg,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: const Text('Eliminar medición',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              subtitle: const Text(
                  'Borrar definitivamente este registro del historial',
                  style: TextStyle(fontSize: 12)),
              trailing:
                  const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(ctx);
                _confirmarEliminarMedicion(context, reg);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminarMedicion(BuildContext context, VitalSign reg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('¿Eliminar medición?'),
          ],
        ),
        content: Text(
          'Se eliminará este registro de ${reg.valorFormateado} (${reg.fechaYHoraFormateada}) para toda la familia.',
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
              final provider = context.read<PatientProvider>();
              await provider.eliminarRegistro(reg.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Medición eliminada'),
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

  String _emojiPorTipo(VitalType t) {
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
