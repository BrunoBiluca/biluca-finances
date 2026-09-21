import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:biluca_financas/app/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ObsidianWealthDarkTheme extends AppTheme {
  // Base colors
  static const Color canvasBase = Color(0xFF090D16);
  static const Color cardSurface = Color(0xFF181B25);
  static const Color raisedSurface = Color(0xFF1A243B);
  static const Color hairlineBorder = Color(0xFF1E293B);

  // Semantic colors
  static const Color positiveYield = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFF43F5E);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color secondaryIndigo = Color(0xFF6366F1);

  // Text colors
  static const Color titleText = Color(0xFFF8FAFC);
  static const Color bodyText = Color(0xFFBDC8D1);
  static const Color textHigh = Color(0xFFF8FAFC);
  static const Color textMedium = Color(0xFF94A3B8);
  static const Color textLow = Color(0xFF64748B);

  // Typography
  static const String fontGeist = 'Geist';
  static const String fontInter = 'Inter';
  static const String fontJetBrainsMono = 'JetBrainsMono';

  @override
  String get name => "Obsidian Wealth Dark";

  @override
  ThemeData build() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: secondaryIndigo,
        surface: cardSurface,
        error: expenseRed,
        onPrimary: Color(0xFF00354A),
        onSecondary: Color(0xFF003824),
        onSurface: textHigh,
        onError: Color(0xFF690005),
        primaryContainer: Color(0xFF38BDF8),
        secondaryContainer: Color(0xFF00A572),
        tertiary: Color(0xFFFFBCBF),
        tertiaryContainer: Color(0xFFFF929A),
      ),

      // Scaffold
      scaffoldBackgroundColor: Color(0xFF0F131C),

      // Card
      cardTheme: CardThemeData(
        color: Color(0xFF1C1F29),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: cardSurface,
        foregroundColor: textHigh,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontGeist,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textHigh,
          letterSpacing: -0.015,
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: Color(0xFF0A0E17),
        elevation: 0,
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontGeist,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textHigh,
          letterSpacing: -0.03,
          height: 1.22,
        ),
        displayMedium: TextStyle(
          fontFamily: fontGeist,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textHigh,
          letterSpacing: -0.02,
          height: 1.28,
        ),
        displaySmall: TextStyle(
          fontFamily: fontGeist,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textHigh,
          letterSpacing: -0.015,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontGeist,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textHigh,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontInter,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: bodyText,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: bodyText,
          height: 1.375,
        ),
        bodySmall: TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: bodyText,
          height: 1.125,
        ),
        labelLarge: TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textHigh,
          height: 1.25,
        ),
        labelMedium: TextStyle(
          fontFamily: fontInter,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textLow,
          height: 0.875,
          letterSpacing: 0.02,
        ),
        labelSmall: TextStyle(
          fontFamily: fontJetBrainsMono,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textMedium,
          height: 1,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: hairlineBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: hairlineBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: expenseRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: expenseRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: textLow),
        labelStyle: const TextStyle(color: textMedium),
        floatingLabelStyle: const TextStyle(color: accentCyan),
        prefixIconColor: textLow,
        suffixIconColor: textLow,
      ),

      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCyan,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontInter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textHigh,
          side: const BorderSide(color: Color(0xFF334155), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontInter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: fontInter,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: cardSurface,
        disabledColor: cardSurface,
        selectedColor: raisedSurface,
        secondarySelectedColor: raisedSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        labelStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMedium,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: accentCyan,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: const BorderSide(color: hairlineBorder, width: 1),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: hairlineBorder,
        thickness: 1,
        space: 1,
      ),

      // List
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: textHigh,
        iconColor: textMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        horizontalTitleGap: 12,
        minVerticalPadding: 10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardSurface,
        selectedIconTheme: const IconThemeData(color: accentCyan),
        unselectedIconTheme: const IconThemeData(color: textMedium),
        selectedLabelTextStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accentCyan,
        ),
        unselectedLabelTextStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textLow,
        ),
        indicatorColor: accentCyan.withValues(alpha: 0.1),
        minWidth: 260,
        groupAlignment: -1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: raisedSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0x14FFFFFF),
            width: 1,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textHigh,
          letterSpacing: -0.015,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: textMedium,
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.all(16),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: raisedSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0x14FFFFFF),
            width: 1,
          ),
        ),
        textStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          color: textHigh,
        ),
      ),

      // Popup Menu
      popupMenuTheme: PopupMenuThemeData(
        color: raisedSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0x14FFFFFF),
            width: 1,
          ),
        ),
        textStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: textHigh,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: raisedSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        showDragHandle: true,
        dragHandleColor: textLow,
      ),

      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: accentCyan,
        unselectedLabelColor: textMedium,
        indicatorColor: accentCyan,
        labelStyle: TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // Time/Dated Picker
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cardSurface,
        dayPeriodColor: cardSurface,
        hourMinuteTextColor: textHigh,
        dayPeriodTextColor: textMedium,
        dialTextColor: textHigh,
        entryModeIconColor: textMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: raisedSurface,
        headerBackgroundColor: cardSurface,
        headerForegroundColor: textHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        dayStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: textHigh,
        ),
        weekdayStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          color: textMedium,
        ),
        yearStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: textMedium,
        ),
        rangePickerHeaderBackgroundColor: cardSurface,
        rangePickerHeaderForegroundColor: textHigh,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentCyan;
          }
          return textLow;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentCyan.withValues(alpha: 0.3);
          }
          return textLow.withValues(alpha: 0.2);
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentCyan;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: hairlineBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentCyan;
          }
          return textLow;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: accentCyan,
        inactiveTrackColor: textLow.withValues(alpha: 0.2),
        thumbColor: accentCyan,
        overlayColor: accentCyan.withValues(alpha: 0.2),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
    );
  }

  @override
  get colors => AppColors(
        positiveYield: Color(0xFF4EDEA3),
        positiveYieldBg: Color(0xFF173E3A),
        positiveYieldAlt: Color(0xFF8CD2FC),
        positiveYieldAltBg: Color(0xFF213F53),
        negativeYield: Color(0xFFFFBCBF),
        negativeYieldBg: Color(0xFF3E1629),
        neutralYield: Color(0xFFBDC8D1),
        neutralYieldBg: Color(0xFF313640),
      );
}
