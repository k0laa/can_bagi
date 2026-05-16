import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/confirmation_screen.dart';
import '../../features/home/screens/sos_error_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/services/sos_service.dart';
import '../../features/help/screens/help_screen.dart';
import '../../features/help/screens/category_form_screen.dart';
import '../../features/tasks/screens/tasks_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final isAuthPage = loc == '/login' || loc == '/register';
        if (authProvider.isLoggedIn && isAuthPage) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/confirmation',
          builder: (context, state) {
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              return ConfirmationScreen(
                response: extra['response'] as SosResponse,
                category: extra['category'] as String?,
              );
            }
            return ConfirmationScreen(response: extra as SosResponse);
          },
        ),
        GoRoute(
          path: '/sos-error',
          builder: (context, state) {
            final error = state.extra as Exception;
            return SosErrorScreen(
              message: error.toString().replaceFirst('Exception: ', ''),
              onRetry: () async => context.go('/'),
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => _ScaffoldWithNav(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
            GoRoute(
              path: '/help',
              builder: (_, __) => const HelpScreen(),
              routes: [
                GoRoute(
                  path: 'form',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>? ?? {};
                    return CategoryFormScreen(
                      categoryId: extra['category'] as String? ?? 'RESCUE',
                      categoryTitle: extra['title'] as String? ?? 'KURTARMA',
                    );
                  },
                ),
              ],
            ),
            GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    );
  }
}

class _ScaffoldWithNav extends StatefulWidget {
  final Widget child;
  const _ScaffoldWithNav({required this.child});

  @override
  State<_ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<_ScaffoldWithNav> {
  bool _dialogShown = false;

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/help'))    return 1;
    if (loc.startsWith('/tasks'))   return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locProvider = context.read<LocationProvider>();
    if (!locProvider.permissionDialogShown && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showLocationPermissionDialog(context, locProvider);
      });
    }
  }

  void _showLocationPermissionDialog(
      BuildContext context, LocationProvider loc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2E45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '📍 Konum İzni',
          style: TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        content: const Text(
          'Acil SOS için konumunuz gereklidir. '
          'Kurtarma ekipleri sizi daha hızlı bulabilir.',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: Color(0xFF8899AA),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Şimdi Değil',
              style: TextStyle(color: Color(0xFF8899AA), fontFamily: 'Nunito'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              loc.requestPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'İzin Ver',
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/');       break;
            case 1: context.go('/help');   break;
            case 2: context.go('/tasks');  break;
            case 3: context.go('/profile'); break;
          }
        },
      ),
    );
  }
}