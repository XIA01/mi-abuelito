import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/vital_sign.dart';
import '../providers/patient_provider.dart';

class LogVitalScreen extends StatefulWidget {
  final VitalType tipo;
  const LogVitalScreen({super.key, required this.tipo});

  @override
  State<LogVitalScreen> createState() => _LogVitalScreenState();
}

class _LogVitalScreenState extends State<LogVitalScreen> {
  // Glucosa
  final _glucosaCtrl = TextEditingController();
  String _momentoGlucosa = 'ayunas';

  // Orina
  int? _orinaCc;
  bool _esPanal = false;
  String? _orinaAspecto;

  // Presión
  final _sistolicaCtrl = TextEditingController();
  final _diastolicaCtrl = TextEditingController();
  final _pulsoCtrl = TextEditingController();

  final _notasCtrl = TextEditingController();
  bool _guardando = false;

  // Fecha y hora del registro (por defecto: ahora)
  DateTime _fechaHora = DateTime.now();

  static const _momentosGlucosa = {
    'ayunas': '☀️ En ayunas',
    'antes_comer': '🍽️ Antes de comer',
    'despues_comer': '⏱️ 2h después de comer',
    'noche': '🌙 Noche',
  };

  static const _ccRapidos = [150, 250, 350, 500, 700, 900, 1200];

  static const _aspectosOrina = {
    'clara': 'Clara 💛',
    'oscura': 'Oscura 🟤',
    'espuma': 'Con espuma 🫧',
  };

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _sistolicaCtrl.dispose();
    _diastolicaCtrl.dispose();
    _pulsoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_titulo),
        backgroundColor: _color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Encabezado visual ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color, _color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(_emoji, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 6),
                  Text(
                    _titulo,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Fecha y Hora del registro ──────────────────────────────────
            _buildFechaHoraPicker(),
            const SizedBox(height: 14),

            // ── Formulario específico ──────────────────────────────────────
            if (widget.tipo == VitalType.glucosa) _buildGlucosaForm(),
            if (widget.tipo == VitalType.orina) _buildOrinaForm(),
            if (widget.tipo == VitalType.presion) _buildPresionForm(),

            const SizedBox(height: 14),

            // ── Notas opcionales ───────────────────────────────────────────
            TextField(
              controller: _notasCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText:
                    'Notas opcionales (ej: estaba nervioso, comió poco...)',
                prefixIcon: const Icon(Icons.notes_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // ── Botón Guardar ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _onGuardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 22),
                label: Text(
                  _guardando ? 'Guardando...' : 'Guardar registro',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Formulario Glucosa ──────────────────────────────────────────────────
  Widget _buildGlucosaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campoNumericoGrande(
          controller: _glucosaCtrl,
          unidad: 'mg/dL',
          color: _color,
          hint: '120',
        ),
        const SizedBox(height: 16),
        _sectionTitle('¿Cuándo se midió?'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _momentosGlucosa.entries.map((e) {
            return ChoiceChip(
              label: Text(e.value),
              selected: _momentoGlucosa == e.key,
              onSelected: (_) =>
                  setState(() => _momentoGlucosa = e.key),
              selectedColor: _color,
              labelStyle: TextStyle(
                color: _momentoGlucosa == e.key
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Formulario Orina ────────────────────────────────────────────────────
  Widget _buildOrinaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_esPanal) ...[
          _sectionTitle('Volumen medido'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ccRapidos.map((cc) {
              final seleccionado = _orinaCc == cc;
              return GestureDetector(
                onTap: () => setState(() => _orinaCc = cc),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: seleccionado ? _color : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: seleccionado
                            ? _color
                            : Colors.grey.shade300),
                    boxShadow: seleccionado
                        ? [
                            BoxShadow(
                                color: _color.withOpacity(0.3),
                                blurRadius: 5)
                          ]
                        : null,
                  ),
                  child: Text(
                    '$cc cc',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: seleccionado
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) =>
                setState(() => _orinaCc = int.tryParse(v)),
            decoration: InputDecoration(
              hintText: 'O escribí otro valor en cc...',
              prefixIcon: const Icon(Icons.edit_outlined),
              suffixText: 'cc',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Color / aspecto (opcional)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _aspectosOrina.entries.map((e) {
              return ChoiceChip(
                label: Text(e.value),
                selected: _orinaAspecto == e.key,
                onSelected: (_) =>
                    setState(() => _orinaAspecto = e.key),
                selectedColor: _color,
                labelStyle: TextStyle(
                  color: _orinaAspecto == e.key
                      ? Colors.white
                      : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 14),
        SwitchListTile.adaptive(
          title: const Text('Registrar como pañal'),
          subtitle: const Text('Cuando no se puede medir en cc'),
          value: _esPanal,
          onChanged: (v) => setState(() => _esPanal = v),
          activeColor: _color,
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ],
    );
  }

  // ─── Formulario Presión ──────────────────────────────────────────────────
  Widget _buildPresionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _campoNumericoGrande(
                controller: _sistolicaCtrl,
                unidad: 'PAS (Sistólica)',
                hint: '120',
                color: _color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '/',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500),
              ),
            ),
            Expanded(
              child: _campoNumericoGrande(
                controller: _diastolicaCtrl,
                unidad: 'PAD (Diastólica)',
                hint: '80',
                color: _color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'mmHg  (Sistólica / Diastólica)',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        _campoNumericoGrande(
          controller: _pulsoCtrl,
          unidad: 'Pulso (latidos por minuto)',
          hint: '72',
          color: Colors.pink.shade300,
        ),
      ],
    );
  }

  // ─── Selector de Fecha y Hora ────────────────────────────────────────────
  Widget _buildFechaHoraPicker() {
    final esHoy = _fechaHora.year == DateTime.now().year &&
        _fechaHora.month == DateTime.now().month &&
        _fechaHora.day == DateTime.now().day;

    final fechaStr = esHoy
        ? 'Hoy'
        : '${_fechaHora.day.toString().padLeft(2, '0')}/'
            '${_fechaHora.month.toString().padLeft(2, '0')}/'
            '${_fechaHora.year}';

    final horaStr =
        '${_fechaHora.hour.toString().padLeft(2, '0')}:${_fechaHora.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Fecha
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              onTap: _seleccionarFecha,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: _color),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade500)),
                        Text(fechaStr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: esHoy ? Colors.green.shade700 : Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 48, color: Colors.grey.shade200),
          // Hora
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
              onTap: _seleccionarHora,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.access_time_outlined,
                        size: 18, color: _color),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hora',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade500)),
                        Text(horaStr,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botón "Ahora"
          if (!esHoy ||
              (_fechaHora.hour != DateTime.now().hour ||
                  _fechaHora.minute != DateTime.now().minute))
            IconButton(
              icon: Icon(Icons.restore, color: Colors.grey.shade500, size: 20),
              tooltip: 'Usar ahora',
              onPressed: () => setState(() => _fechaHora = DateTime.now()),
            ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime(hoy.year - 1),
      lastDate: hoy,
      helpText: '¿Cuándo se tomó la medida?',
    );
    if (picked != null) {
      setState(() {
        _fechaHora = DateTime(
          picked.year, picked.month, picked.day,
          _fechaHora.hour, _fechaHora.minute,
        );
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
      helpText: '¿A qué hora fue?',
    );
    if (picked != null) {
      setState(() {
        _fechaHora = DateTime(
          _fechaHora.year, _fechaHora.month, _fechaHora.day,
          picked.hour, picked.minute,
        );
      });
    }
  }

  // ─── Helpers de UI ───────────────────────────────────────────────────────
  Widget _campoNumericoGrande({
    required TextEditingController controller,
    required String unidad,
    required String hint,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Text(unidad,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: color),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle:
                  TextStyle(fontSize: 40, color: color.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.grey.shade700),
    );
  }

  // ─── Guardar ─────────────────────────────────────────────────────────────
  Future<void> _onGuardar() async {
    final provider = context.read<PatientProvider>();

    VitalSign? registro;

    switch (widget.tipo) {
      case VitalType.glucosa:
        final v = double.tryParse(_glucosaCtrl.text.trim());
        if (v == null) {
          _mostrarError('Ingresá un valor de glucosa válido.');
          return;
        }
        registro = provider.crearRegistroGlucosa(
          valor: v,
          momento: _momentoGlucosa,
          timestamp: _fechaHora,
          notas: _notasCtrl.text.trim().isNotEmpty
              ? _notasCtrl.text.trim()
              : null,
        );
      case VitalType.orina:
        if (!_esPanal && _orinaCc == null) {
          _mostrarError('Seleccioná o ingresá el volumen de orina.');
          return;
        }
        registro = provider.crearRegistroOrina(
          cc: _orinaCc ?? 0,
          esPanal: _esPanal,
          aspecto: _orinaAspecto,
          timestamp: _fechaHora,
          notas: _notasCtrl.text.trim().isNotEmpty
              ? _notasCtrl.text.trim()
              : null,
        );
      case VitalType.presion:
        final s = int.tryParse(_sistolicaCtrl.text.trim());
        final d = int.tryParse(_diastolicaCtrl.text.trim());
        if (s == null || d == null) {
          _mostrarError('Ingresá la presión sistólica y diastólica.');
          return;
        }
        registro = provider.crearRegistroPresion(
          sistolica: s,
          diastolica: d,
          pulso: int.tryParse(_pulsoCtrl.text.trim()),
          timestamp: _fechaHora,
          notas: _notasCtrl.text.trim().isNotEmpty
              ? _notasCtrl.text.trim()
              : null,
        );
    }

    setState(() => _guardando = true);
    await provider.guardarRegistro(registro);
    setState(() => _guardando = false);

    if (mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ ¡Guardado!'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Propiedades visuales por tipo ───────────────────────────────────────
  String get _titulo {
    switch (widget.tipo) {
      case VitalType.glucosa:
        return 'Registrar Azúcar';
      case VitalType.orina:
        return 'Registrar Orina';
      case VitalType.presion:
        return 'Registrar Presión';
    }
  }

  String get _emoji {
    switch (widget.tipo) {
      case VitalType.glucosa:
        return '🩸';
      case VitalType.orina:
        return '💧';
      case VitalType.presion:
        return '💓';
    }
  }

  Color get _color {
    switch (widget.tipo) {
      case VitalType.glucosa:
        return Colors.red.shade600;
      case VitalType.orina:
        return Colors.blue.shade600;
      case VitalType.presion:
        return Colors.pink.shade600;
    }
  }
}
