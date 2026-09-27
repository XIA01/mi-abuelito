import 'package:flutter_test/flutter_test.dart';

import 'package:mi_abuelito/models/patient_profile.dart';
import 'package:mi_abuelito/models/vital_sign.dart';
import 'package:mi_abuelito/providers/patient_provider.dart';

void main() {
  test('PatientProfile se serializa y deserializa sin perder datos', () {
    final perfil = PatientProfile(id: 'ABC234', nombre: 'Rosa', edad: 84);
    final copia = PatientProfile.fromJson(perfil.toJson());

    expect(copia.id, 'ABC234');
    expect(copia.nombre, 'Rosa');
    expect(copia.edad, 84);
    expect(copia.glucosaMax, 180.0);
  });

  test('VitalSign de presión se serializa y deserializa sin perder datos', () {
    final ts = DateTime(2026, 9, 1, 8, 30);
    final registro = VitalSign(
      id: 'r1',
      abueloId: 'ABC234',
      type: VitalType.presion,
      timestamp: ts,
      timeSlot: TimeSlot.fromDateTime(ts),
      familiarNombre: 'Ana',
      parentesco: 'Nieta',
      sistolica: 130,
      diastolica: 85,
      pulso: 72,
    );
    final copia = VitalSign.fromJson(registro.toJson());

    expect(copia.type, VitalType.presion);
    expect(copia.timestamp, ts);
    expect(copia.sistolica, 130);
    expect(copia.diastolica, 85);
    expect(copia.pulso, 72);
  });

  test('Código del abuelo: 8 caracteres, se acepta como se escriba y rechaza los viejos', () {
    expect(PatientProvider.normalizarCodigo('k7qm-4xpa'), 'K7QM4XPA');
    expect(PatientProvider.normalizarCodigo(' K7QM 4XPA '), 'K7QM4XPA');
    expect(PatientProvider.codigoValido('K7QM4XPA'), isTrue);
    expect(PatientProvider.codigoValido('AB12'), isFalse, reason: 'códigos viejos de 4');
    expect(PatientProvider.codigoValido('ABC234'), isFalse, reason: 'códigos de 6');
    expect(PatientProvider.codigoValido('K7QM4XP0'), isFalse, reason: 'el 0 no está en el alfabeto');
    expect(PatientProvider.codigoValido('K1QM4XPA'), isFalse, reason: 'el 1 no está en el alfabeto');
    expect(PatientProvider.formatearCodigo('K7QM4XPA'), 'K7QM-4XPA');
  });
}
