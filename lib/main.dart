import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'providers/patient_provider.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init: $e');
  }

  // Inicializar locale español
  await initializeDateFormatting('es', null);

  // Inicializar AdMob
  await AdService().initialize();

  // Inicializar Notificaciones
  await NotificationService().init();

  runApp(const MiAbuelitoApp());
}

class MiAbuelitoApp extends StatelessWidget {
  const MiAbuelitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientProvider()..inicializar(),
      child: MaterialApp(
        title: 'Mi Abuelito',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade700,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
        home: const _AppEntry(),
      ),
    );
  }
}

/// Redirige según si el perfil ya está configurado o no
class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, provider, _) {
        if (provider.cargando) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('👴', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Cargando...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        if (provider.tienePerfilCargado) {
          return const HomeDashboardScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
