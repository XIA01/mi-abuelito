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
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialReady = false;
              _cargarInterstitial(); // Precargar el siguiente
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial falló al cargar: $error');
          _isInterstitialReady = false;
        },
      ),
    );
  }

  /// Muestra el interstitial si está listo (ej. antes de generar PDF)
  /// Retorna true si se mostró, false si no estaba listo.
  Future<bool> mostrarInterstitial() async {
    if (_isInterstitialReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    }
    return false;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
