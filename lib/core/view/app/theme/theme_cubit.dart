import 'package:material_ui/material_ui.dart';
import 'package:privat_test/core/utils/my_cubit.dart';

class ThemeCubit extends MyCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void toggle(Brightness value) {
    emit(value == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
