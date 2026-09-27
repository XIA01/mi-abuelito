import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/vital_sign.dart';
import '../models/patient_profile.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

enum FiltroFecha { hoy, semana, quincena, mes, todo }
enum FiltroFranja { todas, manana, tarde, noche }

class PatientProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notif = NotificationService();
  final _random = Random.secure();

  PatientProfile? _perfil;
  String _familiarNombre = '';
  String _familiarParentesco = '';
  List<VitalSign> _todosRegistros = [];
  bool _cargando = false;
  String? _error;

  StreamSubscription<List<VitalSign>>? _registrosSub;
  StreamSubscription<PatientProfile?>? _perfilSub;

  FiltroFecha _filtroFecha = FiltroFecha.semana;
  FiltroFranja _filtroFranja = FiltroFranja.todas;

  // ─── Getters públicos ────────────────────────────────────────────────────
  PatientProfile? get perfil => _perfil;
  String get familiarNombre => _familiarNombre;
  String get familiarParentesco => _familiarParentesco;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get tienePerfilCargado => _perfil != null;
  FiltroFecha get filtroFecha => _filtroFecha;
  FiltroFranja get filtroFranja => _filtroFranja;

  List<VitalSign> get todosRegistros => _todosRegistros;

  List<VitalSign> get registrosFiltrados {
    List<VitalSign> resultado = List.from(_todosRegistros);

    // Aplicar filtro de fecha
    final ahora = DateTime.now();
    switch (_filtroFecha) {
      case FiltroFecha.hoy:
        resultado = resultado
            .where((r) =>
                r.timestamp.year == ahora.year &&
                r.timestamp.month == ahora.month &&
                r.timestamp.day == ahora.day)
            .toList();
        break;
      case FiltroFecha.semana:
        final inicio = ahora.subtract(const Duration(days: 7));
        resultado = resultado.where((r) => r.timestamp.isAfter(inicio)).toList();
        break;
      case FiltroFecha.quincena:
        final inicio = ahora.subtract(const Duration(days: 15));
        resultado = resultado.where((r) => r.timestamp.isAfter(inicio)).toList();
        break;
      case FiltroFecha.mes:
        final inicio = ahora.subtract(const Duration(days: 30));
        resultado = resultado.where((r) => r.timestamp.isAfter(inicio)).toList();
        break;
      case FiltroFecha.todo:
        break;
    }

    // Aplicar filtro de franja horaria
    if (_filtroFranja != FiltroFranja.todas) {
      final slot = _filtroFranja == FiltroFranja.manana
          ? TimeSlot.manana
          : _filtroFranja == FiltroFranja.tarde
              ? TimeSlot.tarde
              : TimeSlot.noche;
      resultado = resultado.where((r) => r.timeSlot == slot).toList();
    }

    return resultado;
  }

  // Últimas mediciones por tipo (para el dashboard)
  VitalSign? get ultimaGlucosa => _todosRegistros
      .where((r) => r.type == VitalType.glucosa)
      .firstOrNull;

  VitalSign? get ultimaPresion => _todosRegistros
      .where((r) => r.type == VitalType.presion)
      .firstOrNull;

  VitalSign? get ultimaOrina => _todosRegistros
      .where((r) => r.type == VitalType.orina)
      .firstOrNull;

  // Resumen ejecutivo calculado para la cabecera del médico
  Map<String, dynamic> get resumenMedico {
    final regs = registrosFiltrados;
    final glucosas = regs
        .where((r) => r.type == VitalType.glucosa && r.glucosaValor != null)
        .map((r) => r.glucosaValor!)
        .toList();
    final presiones =
        regs.where((r) => r.type == VitalType.presion && r.sistolica != null).toList();
    final orinas = regs
        .where((r) => r.type == VitalType.orina && r.orinaCc != null)
        .map((r) => r.orinaCc!)
        .toList();

    return {
      'glucosaPromedio': glucosas.isNotEmpty
          ? glucosas.reduce((a, b) => a + b) / glucosas.length
          : null,
      'glucosaMax': glucosas.isNotEmpty
          ? glucosas.reduce((a, b) => a > b ? a : b)
          : null,
      'glucosaMin': glucosas.isNotEmpty
          ? glucosas.reduce((a, b) => a < b ? a : b)
          : null,
      'pasPromedio': presiones.isNotEmpty
          ? presiones.map((r) => r.sistolica!).reduce((a, b) => a + b) /
              presiones.length
          : null,
      'padPromedio': presiones.isNotEmpty
          ? presiones.map((r) => r.diastolica!).reduce((a, b) => a + b) /
              presiones.length
          : null,
      'orinaTotal': orinas.isNotEmpty ? orinas.reduce((a, b) => a + b) : null,
      'totalRegistros': regs.length,
    };
  }

  String get filtroFechaLabel {
    switch (_filtroFecha) {
      case FiltroFecha.hoy:
        return 'Hoy';
      case FiltroFecha.semana:
        return 'Últimos 7 días';
      case FiltroFecha.quincena:
        return 'Últimos 15 días';
      case FiltroFecha.mes:
        return 'Este mes';
      case FiltroFecha.todo:
        return 'Todo el historial';
    }
  }

  // ─── Inicialización ──────────────────────────────────────────────────────
  Future<void> inicializar() async {
    _cargando = true;
    notifyListeners();
    try {
      _perfil = await _db.cargarPerfil();
      final familiar = await _db.cargarFamiliar();
      _familiarNombre = familiar['nombre'] ?? '';
      _familiarParentesco = familiar['parentesco'] ?? '';
      if (_perfil != null) {
        // Mostrar la caché local al instante; el stream trae los datos de la nube
        _todosRegistros = await _db.cargarRegistrosLocales(_perfil!.id);
        _iniciarStream();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void _iniciarStream() {
    _registrosSub?.cancel();
    _perfilSub?.cancel();
    if (_perfil == null) return;
    try {
      // 1. Escuchar la ficha del abuelo (si alguien la borra, salir automáticamente)
      _perfilSub = _db.streamPerfil(_perfil!.id).listen(
        (perfilCloud) {
          if (perfilCloud == null) {
            // El abuelo fue eliminado de la nube por otro familiar
            salirDeEsteDispositivo();
          } else {
            _perfil = perfilCloud;
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('Error en stream de perfil: $e');
        },
      );

      // 2. Escuchar registros de signos vitales en tiempo real
      _registrosSub = _db.streamRegistros(_perfil!.id).listen(
        (nuevos) {
          _todosRegistros = nuevos;
          _db.guardarCacheLocal(_perfil!.id, nuevos);
          notifyListeners();
        },
        onError: (e) {
          debugPrint('Error en stream de registros: $e');
        },
      );
    } catch (e) {
      debugPrint('Error iniciando streams: $e');
    }
  }

  // ─── Creación del perfil del abuelo ─────────────────────────────────────
  Future<void> crearPerfil({
    required String nombre,
    required int edad,
    required String familiarNombre,
    required String familiarParentesco,
  }) async {
    // Evitar pisar la ficha de otra familia si el código ya existe
    String id = _generarIdCorto();
    for (int i = 0; i < 5 && await _db.buscarPerfilEnNube(id) != null; i++) {
      id = _generarIdCorto();
    }
    final perfil = PatientProfile(
      id: id,
      nombre: nombre,
      edad: edad,
    );
    await _db.guardarPerfil(perfil);
    await _db.guardarFamiliar(familiarNombre, familiarParentesco);
    _perfil = perfil;
    _familiarNombre = familiarNombre;
    _familiarParentesco = familiarParentesco;
    _todosRegistros = [];
    _iniciarStream();
    notifyListeners();
  }

  // ─── Unirse con código existente ─────────────────────────────────────────
  Future<void> unirseConCodigo({
    required String codigo,
    required String familiarNombre,
    required String familiarParentesco,
  }) async {
    final codigoUpper = normalizarCodigo(codigo);
    if (!codigoValido(codigoUpper)) {
      _error = 'El código tiene 8 letras y números (ej: K7QM-4XPA). Revisalo.';
      notifyListeners();
      return;
    }
    _cargando = true;
    notifyListeners();

    try {
      // 1. Buscar el abuelo en la nube
      final perfil = await _db.buscarPerfilEnNube(codigoUpper);
      if (perfil == null) {
        // No crear una ficha vacía por un código mal escrito
        _error = 'No encontramos ese código. Revisalo y verificá tu conexión.';
        return;
      }
      _error = null;

      await _db.guardarPerfil(perfil);
      await _db.guardarFamiliar(familiarNombre, familiarParentesco);
      _perfil = perfil;
      _familiarNombre = familiarNombre;
      _familiarParentesco = familiarParentesco;

      _todosRegistros = await _db.cargarRegistrosLocales(perfil.id);
      _iniciarStream();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ─── Guardar registro de signo vital ────────────────────────────────────
  Future<void> guardarRegistro(VitalSign registro) async {
    if (_perfil == null) return;
    _cargando = true;
    notifyListeners();
    try {
      final guardado = await _db.guardarRegistro(registro);
      await _notif.notificarNuevoRegistro(guardado);
      _todosRegistros = [
        guardado,
        ..._todosRegistros.where((r) => r.id != guardado.id),
      ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> eliminarRegistro(String registroId) async {
    if (_perfil == null) return;
    await _db.eliminarRegistro(_perfil!.id, registroId);
    _todosRegistros = _todosRegistros.where((r) => r.id != registroId).toList();
    notifyListeners();
  }

  // ─── Salir de este dispositivo (mantiene registros para otros) ─────────────
  Future<void> salirDeEsteDispositivo() async {
    _cargando = true;
    notifyListeners();
    _registrosSub?.cancel();
    _perfilSub?.cancel();
    await _db.salirDeEsteDispositivo();
    _perfil = null;
    _familiarNombre = '';
    _familiarParentesco = '';
    _todosRegistros = [];
    _cargando = false;
    notifyListeners();
  }

  // ─── Eliminar abuelo y todos sus datos en este dispositivo ─────────────────
  Future<void> eliminarAbueloYDatos() async {
    if (_perfil == null) return;
    _cargando = true;
    notifyListeners();
    _registrosSub?.cancel();
    _perfilSub?.cancel();
    await _db.eliminarAbueloYRegistros(_perfil!.id);
    _perfil = null;
    _familiarNombre = '';
    _familiarParentesco = '';
    _todosRegistros = [];
    _cargando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _registrosSub?.cancel();
    _perfilSub?.cancel();
    super.dispose();
  }

  // ─── Filtros ─────────────────────────────────────────────────────────────
  void setFiltroFecha(FiltroFecha f) {
    _filtroFecha = f;
    notifyListeners();
  }

  void setFiltroFranja(FiltroFranja f) {
    _filtroFranja = f;
    notifyListeners();
  }

  // ─── Código del abuelo ──────────────────────────────────────────────────
  // 8 caracteres de un alfabeto sin símbolos que se confunden (sin I, O, 0 ni 1):
  // 32^8 ≈ 1 billón de combinaciones, inviable de adivinar probando aunque haya miles
  // de familias. Se guarda sin guion ("K7QM4XPA") y se muestra como "K7QM-4XPA".
  // Las reglas de Firestore (firestore.rules) sólo aceptan este formato.
  static const _alfabetoCodigo = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static final _formatoCodigo = RegExp(r'^[A-HJ-NP-Z2-9]{8}$');

  /// Acepta el código como lo escriba la persona: minúsculas, con guion o espacios.
  static String normalizarCodigo(String valor) =>
      valor.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static bool codigoValido(String codigo) => _formatoCodigo.hasMatch(codigo);

  static String formatearCodigo(String codigo) => codigo.length == 8
      ? '${codigo.substring(0, 4)}-${codigo.substring(4)}'
      : codigo;

  String _generarIdCorto() => List.generate(
      8, (_) => _alfabetoCodigo[_random.nextInt(_alfabetoCodigo.length)]).join();

  VitalSign crearRegistroGlucosa({
    required double valor,
    required String momento,
    DateTime? timestamp,
    String? notas,
  }) {
    final ts = timestamp ?? DateTime.now();
    return VitalSign(
      id: '',
      abueloId: _perfil!.id,
      type: VitalType.glucosa,
      timestamp: ts,
      timeSlot: TimeSlot.fromDateTime(ts),
      familiarNombre: _familiarNombre,
      parentesco: _familiarParentesco,
      glucosaValor: valor,
      glucosaMomento: momento,
      notas: notas,
    );
  }

  VitalSign crearRegistroOrina({
    required int cc,
    bool esPanal = false,
    String? aspecto,
    DateTime? timestamp,
    String? notas,
  }) {
    final ts = timestamp ?? DateTime.now();
    return VitalSign(
      id: '',
      abueloId: _perfil!.id,
      type: VitalType.orina,
      timestamp: ts,
      timeSlot: TimeSlot.fromDateTime(ts),
      familiarNombre: _familiarNombre,
      parentesco: _familiarParentesco,
      orinaCc: cc,
      esPanal: esPanal,
      orinaAspecto: aspecto,
      notas: notas,
    );
  }

  VitalSign crearRegistroPresion({
    required int sistolica,
    required int diastolica,
    int? pulso,
    DateTime? timestamp,
    String? notas,
  }) {
    final ts = timestamp ?? DateTime.now();
    return VitalSign(
      id: '',
      abueloId: _perfil!.id,
      type: VitalType.presion,
      timestamp: ts,
      timeSlot: TimeSlot.fromDateTime(ts),
      familiarNombre: _familiarNombre,
      parentesco: _familiarParentesco,
      sistolica: sistolica,
      diastolica: diastolica,
      pulso: pulso,
      notas: notas,
    );
  }
}
