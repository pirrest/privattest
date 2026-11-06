import 'package:material_ui/material_ui.dart';

ThemeData createMainTheme({required Brightness brightness}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.lightBlue,
    brightness: brightness,
  );

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
