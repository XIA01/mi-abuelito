import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../widgets/doctor_summary_header.dart';
import '../widgets/doctor_table_row.dart';
import '../services/pdf_report_service.dart';
import '../services/ad_service.dart';

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
    await PdfReportService().generarYCompartirReporte(
      perfil: provider.perfil!,
      registros: provider.registrosFiltrados,
      periodoLabel: provider.filtroFechaLabel,
      context: context,
    );
    setState(() => _exportando = false);
  }
}
