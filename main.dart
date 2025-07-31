import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:characedit/main_shell.dart';
import 'package:characedit/providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PrakashAIApp(),
    ),
  );
}

class PrakashAIApp extends ConsumerWidget {
  const PrakashAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'PrakashAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: themeMode,
      home: const MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}