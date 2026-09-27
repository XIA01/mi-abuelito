import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/vital_sign.dart';
import '../models/patient_profile.dart';

class DatabaseService {
  static const String _registrosKey = 'vital_signs';
  static const String _perfilKey = 'patient_profile';
  static const String _familiarKey = 'familiar_name';
  static const String _parentescoKey = 'familiar_parentesco';

  final _uuid = const Uuid();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ─── Perfil del Abuelo ───────────────────────────────────────────────────
  Future<void> guardarPerfil(PatientProfile perfil) async {
    // 1. Guardar localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_perfilKey, jsonEncode(perfil.toJson()));

    // 2. Guardar en la nube (Firestore)
    try {
      await _firestore
          .collection('abuelos')
          .doc(perfil.id)
          .set(perfil.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error guardando perfil en Firestore: $e');
    }
  }

  Future<PatientProfile?> cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_perfilKey);
    if (raw == null) return null;
    try {
      final local = PatientProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // Intentar refrescar desde la nube en segundo plano
      _firestore.collection('abuelos').doc(local.id).get().then((doc) {
        if (doc.exists && doc.data() != null) {
          final cloud = PatientProfile.fromJson(doc.data()!);
          prefs.setString(_perfilKey, jsonEncode(cloud.toJson()));
        }
      }).catchError((_) {});
      return local;
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
      return null;
    }
  }

  /// Busca un abuelo por su código en la nube (para 'Tengo un código')
  Future<PatientProfile?> buscarPerfilEnNube(String codigo) async {
    try {
      final doc = await _firestore
          .collection('abuelos')
          .doc(codigo.trim().toUpperCase())
          .get();

      if (doc.exists && doc.data() != null) {
        return PatientProfile.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error buscando abuelo en la nube: $e');
    }
    return null;
  }

  /// Escuchar cambios en la ficha del abuelo (para detectar si otro familiar lo eliminó)
  Stream<PatientProfile?> streamPerfil(String abueloId) {
    return _firestore
        .collection('abuelos')
        .doc(abueloId)
        .snapshots()
        // Un "no existe" que viene de la caché offline no significa que lo hayan borrado
        .where((snap) => snap.exists || !snap.metadata.isFromCache)
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return PatientProfile.fromJson(snap.data()!);
    });
  }

  // ─── Familiar local ──────────────────────────────────────────────────────
  Future<void> guardarFamiliar(String nombre, String parentesco) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_familiarKey, nombre);
    await prefs.setString(_parentescoKey, parentesco);
  }

  Future<Map<String, String>> cargarFamiliar() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nombre': prefs.getString(_familiarKey) ?? '',
      'parentesco': prefs.getString(_parentescoKey) ?? '',
    };
  }

  // ─── Registros de Signos Vitales ─────────────────────────────────────────
  /// Lee solo la caché local (sin lecturas de Firestore)
  Future<List<VitalSign>> cargarRegistrosLocales(String abueloId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_registrosKey}_$abueloId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => VitalSign.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error cargando registros locales: $e');
      return [];
    }
  }

  Future<void> guardarCacheLocal(String abueloId, List<VitalSign> registros) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_registrosKey}_$abueloId',
      jsonEncode(registros.map((e) => e.toJson()).toList()),
    );
  }

  /// Escuchar registros en TIEMPO REAL desde la nube
  Stream<List<VitalSign>> streamRegistros(String abueloId) {
    return _firestore
        .collection('abuelos')
        .doc(abueloId)
        .collection('registros')
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => VitalSign.fromJson(d.data())).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<VitalSign> guardarRegistro(VitalSign registro) async {
    final registros = await cargarRegistrosLocales(registro.abueloId);

    // Asignar ID si no lo tiene
    final nuevoRegistro = registro.id.isEmpty
        ? _clonarConId(registro, _uuid.v4())
        : registro;

    // 1. Guardar localmente
    registros.removeWhere((r) => r.id == nuevoRegistro.id);
    registros.insert(0, nuevoRegistro);
    await guardarCacheLocal(registro.abueloId, registros);

    // 2. Guardar en Firestore. No se espera la confirmación del servidor:
    // sin conexión el Future no termina hasta reconectar y la UI quedaría colgada.
    _firestore
        .collection('abuelos')
        .doc(registro.abueloId)
        .collection('registros')
        .doc(nuevoRegistro.id)
        .set(nuevoRegistro.toJson())
        .catchError((e) => debugPrint('Error guardando registro en Firestore: $e'));

    return nuevoRegistro;
  }

  Future<void> eliminarRegistro(String abueloId, String registroId) async {
    final registros = await cargarRegistrosLocales(abueloId);
    registros.removeWhere((e) => e.id == registroId);
    await guardarCacheLocal(abueloId, registros);

    _firestore
        .collection('abuelos')
        .doc(abueloId)
        .collection('registros')
        .doc(registroId)
        .delete()
        .catchError((e) => debugPrint('Error eliminando de Firestore: $e'));
  }

  Future<void> salirDeEsteDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_perfilKey);
    await prefs.remove(_familiarKey);
    await prefs.remove(_parentescoKey);
  }

  Future<void> eliminarAbueloYRegistros(String abueloId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_perfilKey);
    await prefs.remove(_familiarKey);
    await prefs.remove(_parentescoKey);
    await prefs.remove('${_registrosKey}_$abueloId');

    try {
      // Eliminar registros y perfil en la nube
      final snap = await _firestore
          .collection('abuelos')
          .doc(abueloId)
          .collection('registros')
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      await _firestore.collection('abuelos').doc(abueloId).delete();
    } catch (e) {
      debugPrint('Error eliminando abuelo de Firestore: $e');
    }
  }

  VitalSign _clonarConId(VitalSign r, String newId) {
    return VitalSign(
      id: newId,
      abueloId: r.abueloId,
      type: r.type,
      timestamp: r.timestamp,
      timeSlot: r.timeSlot,
      familiarNombre: r.familiarNombre,
      parentesco: r.parentesco,
      notas: r.notas,
      glucosaValor: r.glucosaValor,
      glucosaMomento: r.glucosaMomento,
      orinaCc: r.orinaCc,
      esPanal: r.esPanal,
      orinaAspecto: r.orinaAspecto,
      sistolica: r.sistolica,
      diastolica: r.diastolica,
      pulso: r.pulso,
    );
  }
}
