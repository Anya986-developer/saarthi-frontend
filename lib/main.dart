import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/applications_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/scheme_detail_screen.dart';
import 'screens/profile_processing_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/application_details_screen.dart';

void main() {
  runApp(const ProviderScope(child: SchemeEngineApp()));
}

//  ROUTER  (top-level so all screens can use context.go/push)

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 1. Splash → auto-navigates to /auth after animation
      GoRoute(
        path: '/',
        builder: (context, state) => SchemeSarthiSplash(
          onComplete: () => context.go('/auth'),
        ),
      ),

      // 2. Auth → login/register → goes to /home (citizen) or /admin
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // 3. Profile form → save → goes to /home
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: '/profile_processing',
        builder: (context, state) => const ProfileProcessingScreen(),
      ),

      // 4. Home screen (scheme list + hero banner)
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final tab = state.extra as int? ?? 0;

          return HomeScreen(initialTab: tab);
        },
      ),

      // 5. Scheme detail — receives scheme map via state.extra
      GoRoute(
        path: '/scheme_detail',
        builder: (context, state) {
          final scheme = state.extra as Map<String, dynamic>? ?? {};
          return SchemeDetailScreen(scheme: scheme);
        },
      ),

      // 6. My Applications
      GoRoute(
        path: '/applications',
        builder: (context, state) => const ApplicationsScreen(),
      ),

      // 7. Admin dashboard (role-guarded on auth side)
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),

      GoRoute(
        path: '/application_details',
        builder: (context, state) {
          final applicationId = state.extra as String;

          return ApplicationDetailScreen(
            applicationId: applicationId,
          );
        },
      ),
    ],

    // If any unknown route is hit, fall back to splash
    errorBuilder: (context, state) => SchemeSarthiSplash(
      onComplete: () => context.go('/auth'),
    ),
  );
});

//  APP WIDGET
class SchemeEngineApp extends ConsumerWidget {
  const SchemeEngineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Scheme Sarthi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF185FA5),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF0C447C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF185FA5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      routerConfig: router,
    );
  }
}
