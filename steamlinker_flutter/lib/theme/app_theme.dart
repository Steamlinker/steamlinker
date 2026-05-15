import 'package:flutter/material.dart';
import 'colors.dart';

class SteamTheme {
  SteamTheme._();

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: SteamColors.bgDeep,
        fontFamily: 'Roboto',
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? Colors.white
                : SteamColors.muted,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? SteamColors.teal
                : SteamColors.border,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: SteamColors.blue,
          surface: SteamColors.bgCard,
        ),
      );
}
