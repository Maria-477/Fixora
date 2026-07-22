import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/language/language_selection_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const _PlaceholderLoginScreen(),
    ),
  ],
);

class _PlaceholderLoginScreen extends StatelessWidget {
  const _PlaceholderLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login screen coming in Milestone 7'),
      ),
    );
  }
}