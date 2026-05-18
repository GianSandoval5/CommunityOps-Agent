import 'package:flutter/material.dart';

import 'app_config.dart';
import '../core/theme/app_colors.dart';
import '../features/event_ops/data/api_event_ops_repository.dart';
import '../features/event_ops/data/in_memory_event_ops_repository.dart';
import '../features/event_ops/presentation/pages/event_ops_page.dart';

class CommunityOpsApp extends StatelessWidget {
  const CommunityOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppConfig.current.useBackend
        ? ApiEventOpsRepository(baseUrl: AppConfig.current.apiBaseUrl)
        : InMemoryEventOpsRepository();

    return MaterialApp(
      title: 'CommunityOps Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          primary: AppColors.brand,
          secondary: AppColors.accent,
          surface: AppColors.panel,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.ink,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: AppColors.muted,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.panel,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.panel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.brand, width: 1.4),
          ),
        ),
      ),
      home: EventOpsPage(repository: repository),
    );
  }
}
