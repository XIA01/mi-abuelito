import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/vital_sign.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  Future<void> notificarNuevoRegistro(VitalSign registro) async {
    if (kIsWeb) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'vital_signs_channel',
        'Registros de Salud',
        channelDescription: 'Notificaciones cuando un familiar registra un signo vital',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const details = NotificationDetails(android: androidDetails);

      String titulo = '📋 Nuevo registro - ${registro.familiarNombre}';
      String cuerpo = registro.resumenNotificacion;

      // Si el valor es crítico, marcar con alerta visual
      if (registro.severity == ClinicalSeverity.crisis) {
        titulo = '⚠️ ALERTA - Valor crítico registrado';
      } else if (registro.severity == ClinicalSeverity.alerta) {
        titulo = '🟡 ${registro.familiarNombre} registró un valor elevado';
      }

      await _plugin.show(
        registro.hashCode,
        titulo,
        cuerpo,
        details,
      );
    } catch (e) {
      debugPrint('Error enviando notificación: $e');
    }
  }

  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }
}
