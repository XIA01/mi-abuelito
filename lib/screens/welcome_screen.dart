import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../widgets/flag_counter_widget.dart';
import 'home_dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Crear perfil
  final _nombreAbuelo = TextEditingController();
  final _edadAbuelo = TextEditingController();
  final _familiarNombreCrear = TextEditingController();
  final _parentescoCrear = TextEditingController();

  // Unirse
  final _codigoController = TextEditingController();
  final _familiarNombreUnirse = TextEditingController();
  final _parentescoUnirse = TextEditingController();

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreAbuelo.dispose();
    _edadAbuelo.dispose();
    _familiarNombreCrear.dispose();
    _parentescoCrear.dispose();
    _codigoController.dispose();
    _familiarNombreUnirse.dispose();
    _parentescoUnirse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // ── Logo / Encabezado ──────────────────────────────────────────
            const Text('👴', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            Text(
              'Mi Abuelito',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            Text(
              'Cuidados en familia, al alcance de todos',
              style: TextStyle(color: Colors.blue.shade600, fontSize: 14),
            ),
            const SizedBox(height: 28),

            // ── Tabs ──────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blue.shade700,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: '✨ Crear ficha'),
                  Tab(text: '🔗 Tengo un código'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Contenido ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCrearPerfil(),
                  _buildUnirse(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrearPerfil() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _card(
            titulo: '👴 Datos del abuelo',
            children: [
              _campo(_nombreAbuelo, 'Nombre del abuelo/a', Icons.person_outline),
              const SizedBox(height: 12),
              _campo(_edadAbuelo, 'Edad', Icons.cake_outlined,
                  tipo: TextInputType.number),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            titulo: '🙋 ¿Vos quién sos?',
            children: [
              _campo(_familiarNombreCrear, 'Tu nombre (ej: Sofía)',
                  Icons.face_outlined),
              const SizedBox(height: 12),
              _campo(_parentescoCrear, 'Parentesco (ej: Nieta, Hija, Enfermera)',
                  Icons.people_outline),
            ],
          ),
          const SizedBox(height: 20),
          _botonPrincipal('Crear ficha y obtener código', _onCrearPerfil),
          const SizedBox(height: 18),
          const FlagCounterWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUnirse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _card(
            titulo: '🔑 Código del abuelo',
            children: [
              TextField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'A 4 5 3',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 28,
                      letterSpacing: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  counterText: '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Pedile el código a quien creó la ficha del abuelo',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            titulo: '🙋 ¿Vos quién sos?',
            children: [
              _campo(_familiarNombreUnirse, 'Tu nombre (ej: Carlos)',
                  Icons.face_outlined),
              const SizedBox(height: 12),
              _campo(_parentescoUnirse, 'Parentesco (ej: Hijo, Cuidadora)',
                  Icons.people_outline),
            ],
          ),
          const SizedBox(height: 20),
          _botonPrincipal('Unirme a la familia', _onUnirse),
          const SizedBox(height: 18),
          const FlagCounterWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _card({required String titulo, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.shade100,
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  fontSize: 14)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _campo(TextEditingController c, String hint, IconData icon,
      {TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: tipo,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _botonPrincipal(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _cargando ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: _cargando
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _onCrearPerfil() async {
    if (_nombreAbuelo.text.trim().isEmpty ||
        _familiarNombreCrear.text.trim().isEmpty) {
      _mostrarError('Completá el nombre del abuelo y el tuyo.');
      return;
    }
    setState(() => _cargando = true);
    final provider = context.read<PatientProvider>();
    await provider.crearPerfil(
      nombre: _nombreAbuelo.text.trim(),
      edad: int.tryParse(_edadAbuelo.text) ?? 0,
      familiarNombre: _familiarNombreCrear.text.trim(),
      familiarParentesco: _parentescoCrear.text.trim(),
    );
    setState(() => _cargando = false);
    if (mounted && provider.tienePerfilCargado) {
      _mostrarCodigoYContinuar(provider.perfil!.id);
    }
  }

  Future<void> _onUnirse() async {
    if (_codigoController.text.trim().length < 4 ||
        _familiarNombreUnirse.text.trim().isEmpty) {
      _mostrarError('Ingresá el código y tu nombre.');
      return;
    }
    setState(() => _cargando = true);
    final provider = context.read<PatientProvider>();
    await provider.unirseConCodigo(
      codigo: _codigoController.text.trim(),
      familiarNombre: _familiarNombreUnirse.text.trim(),
      familiarParentesco: _parentescoUnirse.text.trim(),
    );
    setState(() => _cargando = false);
    if (mounted && provider.tienePerfilCargado) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
      );
    }
  }

  void _mostrarCodigoYContinuar(String codigo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 ¡Ficha creada!',
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Este es el código para que la familia se conecte:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade300, width: 2),
              ),
              child: Text(
                codigo,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  letterSpacing: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Compartilo por WhatsApp con la familia para que todos puedan anotar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const HomeDashboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('¡Empezar a registrar!'),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
