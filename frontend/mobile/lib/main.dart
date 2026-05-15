import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/providers/connection_provider.dart';
import 'core/providers/location_provider.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Afet senaryosu: fontlar bundle'da, network'e fallback kapalı
  GoogleFonts.config.allowRuntimeFetching = false;
  final prefs = await SharedPreferences.getInstance();
  runApp(MeshAidApp(prefs: prefs));
}

class MeshAidApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MeshAidApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ConnectionProvider()..startMonitoring()),
        ChangeNotifierProvider(create: (_) => LocationProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router;
          return MaterialApp.router(
            title: 'MeshAid',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.accent,
                error: AppColors.danger,
                surface: AppColors.card,
              ),
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
