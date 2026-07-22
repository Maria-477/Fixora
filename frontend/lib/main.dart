import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FixoraApp(),
    ),
  );
}

class FixoraApp extends StatelessWidget {
  const FixoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fixora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}