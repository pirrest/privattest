import 'package:material_ui/material_ui.dart';

ThemeData createMainTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.lightBlue);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
  );
}
