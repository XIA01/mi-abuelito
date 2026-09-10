class PatientProfile {
  final String id; // Código familiar, ej: A453
  final String nombre;
  final int edad;
  final String? grupoSanguineo;
  final String? contactoEmergencia;
  final String? medicoCabecera;
  final List<String> cuidadoresRegistrados;

  // Metas clínicas personalizadas
  final double glucosaMin;
  final double glucosaMax;
  final int presionSistolicaMax;
  final int presionDiastolicaMax;

  PatientProfile({
    required this.id,
    required this.nombre,
    required this.edad,
    this.grupoSanguineo,
    this.contactoEmergencia,
    this.medicoCabecera,
    this.cuidadoresRegistrados = const [],
    this.glucosaMin = 70.0,
    this.glucosaMax = 180.0,
    this.presionSistolicaMax = 140,
    this.presionDiastolicaMax = 90,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'grupoSanguineo': grupoSanguineo,
      'contactoEmergencia': contactoEmergencia,
      'medicoCabecera': medicoCabecera,
      'cuidadoresRegistrados': cuidadoresRegistrados,
      'glucosaMin': glucosaMin,
      'glucosaMax': glucosaMax,
      'presionSistolicaMax': presionSistolicaMax,
      'presionDiastolicaMax': presionDiastolicaMax,
    };
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      edad: json['edad'] as int? ?? 80,
      grupoSanguineo: json['grupoSanguineo'] as String?,
      contactoEmergencia: json['contactoEmergencia'] as String?,
      medicoCabecera: json['medicoCabecera'] as String?,
      cuidadoresRegistrados: List<String>.from(json['cuidadoresRegistrados'] ?? []),
      glucosaMin: (json['glucosaMin'] as num?)?.toDouble() ?? 70.0,
      glucosaMax: (json['glucosaMax'] as num?)?.toDouble() ?? 180.0,
      presionSistolicaMax: json['presionSistolicaMax'] as int? ?? 140,
      presionDiastolicaMax: json['presionDiastolicaMax'] as int? ?? 90,
    );
  }

  PatientProfile copyWith({
    String? id,
    String? nombre,
    int? edad,
    String? grupoSanguineo,
    String? contactoEmergencia,
    String? medicoCabecera,
    List<String>? cuidadoresRegistrados,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      grupoSanguineo: grupoSanguineo ?? this.grupoSanguineo,
      contactoEmergencia: contactoEmergencia ?? this.contactoEmergencia,
      medicoCabecera: medicoCabecera ?? this.medicoCabecera,
      cuidadoresRegistrados: cuidadoresRegistrados ?? this.cuidadoresRegistrados,
      glucosaMin: glucosaMin,
      glucosaMax: glucosaMax,
      presionSistolicaMax: presionSistolicaMax,
      presionDiastolicaMax: presionDiastolicaMax,
    );
  }
}
