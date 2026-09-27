import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // ─── IDs de prueba oficiales de Google (seguros para desarrollo) ──────────
  // IMPORTANTE: Para producción, reemplazar con tus IDs reales de AdMob Console
  static const String _testBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // ─── IDs de PRODUCCIÓN (tus IDs reales de AdMob) ─────────────────────────
  static const String _prodBannerId =
      'ca-app-pub-7786022670300618/7728421519';
  static const String _prodInterstitialId =
      'ca-app-pub-7786022670300618/5301568724';

  static String get bannerId =>
      kDebugMode ? _testBannerId : _prodBannerId;
  static String get interstitialId =>
      kDebugMode ? _testInterstitialId : _prodInterstitialId;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  int _reintentosCarga = 0;

  // ─── Inicialización del SDK ───────────────────────────────────────────────
  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    _cargarInterstitial();
  }

  // ─── Banner Ad ───────────────────────────────────────────────────────────
  BannerAd? crearBanner() {
    if (kIsWeb) return null;
    return BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  // ─── Interstitial Ad (para la exportación de PDF) ────────────────────────
  void _cargarInterstitial() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          _reintentosCarga = 0;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial falló al cargar: $error');
          _isInterstitialReady = false;
          // Reintentar con espera creciente (30s, 60s, 120s) en vez de quedarse sin anuncio toda la sesión
          if (_reintentosCarga < 3) {
            final espera = Duration(seconds: 30 << _reintentosCarga);
            _reintentosCarga++;
            Future.delayed(espera, _cargarInterstitial);
          }
        },
      ),
    );
  }

  /// Muestra el interstitial si está listo (ej. antes de generar PDF) y espera a que se cierre.
  /// Retorna true si se mostró, false si no estaba listo.
  Future<bool> mostrarInterstitial() async {
    final ad = _interstitialAd;
    if (!_isInterstitialReady || ad == null) return false;

    final cerrado = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!cerrado.isCompleted) cerrado.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial falló al mostrarse: $error');
        ad.dispose();
        if (!cerrado.isCompleted) cerrado.complete(false);
      },
    );
    _interstitialAd = null;
    _isInterstitialReady = false;
    await ad.show();
    final mostrado = await cerrado.future;
    _cargarInterstitial(); // Precargar el siguiente
    return mostrado;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
