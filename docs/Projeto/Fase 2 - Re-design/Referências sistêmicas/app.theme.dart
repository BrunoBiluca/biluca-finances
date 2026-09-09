import 'package:flutter/material.dart';

class AppTheme {
  // Base colors
  static const Color canvasBase = Color(0xFF090D16);
  static const Color cardSurface = Color(0xFF131B2E);
  static const Color raisedSurface = Color(0xFF1A243B);
  static const Color hairlineBorder = Color(0xFF1E293B);
  
  // Semantic colors
  static const Color positiveYield = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFF43F5E);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color secondaryIndigo = Color(0xFF6366F1);
  
  // Text colors
  static const Color textHigh = Color(0xFFF8FAFC);
  static const Color textMedium = Color(0xFF94A3B8);
  static const Color textLow = Color(0xFF64748B);
  
  // Typography
  static const String fontGeist = 'Geist';
  static const String fontInter = 'Inter';
  static const String fontJetBrainsMono = 'JetBrainsMono';

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: secondaryIndigo,
        surface: cardSurface,
        background: canvasBase,
        error: expenseRed,
        onPrimary: Color(0xFF00354A),
        onSecondary: Color(0xFF003824),
        onSurface: textHigh,
        onBackground: textHigh,
        onError: Color(0xFF690005),
        primaryContainer: Color(0xFF38BDF8),
        secondaryContainer: Color(0xFF00A572),
        tertiary: Color(0xFFFFBCBF),
        tertiaryContainer: Color(0xFFFF929A),
      ),

      // Scaffold
      scaffoldBackgroundColor: canvasBase,

      // Card
      cardTheme: CardTheme(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: hairlineBorder,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
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
          color: textHigh,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMedium,
          height: 1.375,
        ),
        bodySmall: TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textLow,
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
        indicatorColor: accentCyan.withOpacity(0.1),
        minWidth: 260,
        groupAlignment: -1,
      ),

      // Dialog
      dialogTheme: DialogTheme(
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
      tabBarTheme: const TabBarTheme(
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
        backgroundColor: raisedSurface,
        hourMinuteColor: MaterialStatePropertyAll(cardSurface),
        dayPeriodColor: MaterialStatePropertyAll(cardSurface),
        hourMinuteTextColor: MaterialStatePropertyAll(textHigh),
        dayPeriodTextColor: MaterialStatePropertyAll(textMedium),
        dialTextColor: MaterialStatePropertyAll(textHigh),
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
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accentCyan;
          }
          return textLow;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accentCyan.withOpacity(0.3);
          }
          return textLow.withOpacity(0.2);
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accentCyan;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: hairlineBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accentCyan;
          }
          return textLow;
        }),
      ),
      
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: accentCyan,
        inactiveTrackColor: textLow.withOpacity(0.2),
        thumbColor: accentCyan,
        overlayColor: accentCyan.withOpacity(0.15),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
    );
  }

  // Light Theme (based on inverse colors from the design system)
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF00668A),
        secondary: Color(0xFF005236),
        surface: Color(0xFFDFE2EF),
        background: Color(0xFFDFE2EF),
        error: Color(0xFFBA1A1A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF2C303A),
        onBackground: Color(0xFF2C303A),
        onError: Colors.white,
        primaryContainer: Color(0xFFC4E7FF),
        secondaryContainer: Color(0xFF6FFBBE),
        tertiary: Color(0xFF40000D),
        tertiaryContainer: Color(0xFFFFDADB),
      ),
      
      scaffoldBackgroundColor: const Color(0xFFDFE2EF),
      
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFBDBDBD),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFDFE2EF),
        foregroundColor: Color(0xFF2C303A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontGeist,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C303A),
          letterSpacing: -0.015,
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontGeist,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2C303A),
          letterSpacing: -0.03,
          height: 1.22,
        ),
        displayMedium: TextStyle(
          fontFamily: fontGeist,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C303A),
          letterSpacing: -0.02,
          height: 1.28,
        ),
        displaySmall: TextStyle(
          fontFamily: fontGeist,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C303A),
          letterSpacing: -0.015,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontGeist,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C303A),
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontInter,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF2C303A),
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4A4E58),
          height: 1.375,
        ),
        bodySmall: TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6A6E78),
          height: 1.125,
        ),
        labelLarge: TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2C303A),
          height: 1.25,
        ),
        labelMedium: TextStyle(
          fontFamily: fontInter,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6A6E78),
          height: 0.875,
          letterSpacing: 0.02,
        ),
        labelSmall: TextStyle(
          fontFamily: fontJetBrainsMono,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A4E58),
          height: 1,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00668A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: Color(0xFF6A6E78)),
        labelStyle: const TextStyle(color: Color(0xFF4A4E58)),
        floatingLabelStyle: const TextStyle(color: Color(0xFF00668A)),
        prefixIconColor: Color(0xFF6A6E78),
        suffixIconColor: Color(0xFF6A6E78),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00668A),
          foregroundColor: Colors.white,
          elevation: 1,
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
          foregroundColor: const Color(0xFF2C303A),
          side: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
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
          foregroundColor: const Color(0xFF00668A),
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
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        disabledColor: Colors.white,
        selectedColor: const Color(0xFFC4E7FF),
        secondarySelectedColor: const Color(0xFFC4E7FF),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        labelStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A4E58),
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF00668A),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: const BorderSide(color: Color(0xFFBDBDBD), width: 0.5),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFFBDBDBD),
        thickness: 0.5,
        space: 0.5,
      ),
      
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: const Color(0xFF2C303A),
        iconColor: const Color(0xFF4A4E58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        horizontalTitleGap: 12,
        minVerticalPadding: 10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
      
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: const IconThemeData(color: Color(0xFF00668A)),
        unselectedIconTheme: const IconThemeData(color: Color(0xFF4A4E58)),
        selectedLabelTextStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00668A),
        ),
        unselectedLabelTextStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6A6E78),
        ),
        indicatorColor: Color(0xFF00668A).withOpacity(0.1),
        minWidth: 260,
        groupAlignment: -1,
      ),
      
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0x1A000000),
            width: 1,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontGeist,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C303A),
          letterSpacing: -0.015,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: Color(0xFF4A4E58),
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.all(16),
      ),
      
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF2C303A),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0x1A000000),
            width: 1,
          ),
        ),
        textStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: Color(0xFF2C303A),
        ),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        showDragHandle: true,
        dragHandleColor: Color(0xFF6A6E78),
      ),
      
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xFF00668A),
        unselectedLabelColor: Color(0xFF4A4E58),
        indicatorColor: Color(0xFF00668A),
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
      
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        hourMinuteColor: MaterialStatePropertyAll(const Color(0xFFF5F5F5)),
        dayPeriodColor: MaterialStatePropertyAll(const Color(0xFFF5F5F5)),
        hourMinuteTextColor: MaterialStatePropertyAll(const Color(0xFF2C303A)),
        dayPeriodTextColor: MaterialStatePropertyAll(const Color(0xFF4A4E58)),
        dialTextColor: MaterialStatePropertyAll(const Color(0xFF2C303A)),
        entryModeIconColor: const Color(0xFF4A4E58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: const Color(0xFFF5F5F5),
        headerForegroundColor: const Color(0xFF2C303A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        dayStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: Color(0xFF2C303A),
        ),
        weekdayStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 12,
          color: Color(0xFF4A4E58),
        ),
        yearStyle: const TextStyle(
          fontFamily: fontInter,
          fontSize: 14,
          color: Color(0xFF4A4E58),
        ),
        rangePickerHeaderBackgroundColor: const Color(0xFFF5F5F5),
        rangePickerHeaderForegroundColor: const Color(0xFF2C303A),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00668A);
          }
          return const Color(0xFF6A6E78);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00668A).withOpacity(0.3);
          }
          return const Color(0xFF6A6E78).withOpacity(0.2);
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00668A);
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00668A);
          }
          return const Color(0xFF6A6E78);
        }),
      ),
      
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF00668A),
        inactiveTrackColor: const Color(0xFF6A6E78).withOpacity(0.2),
        thumbColor: const Color(0xFF00668A),
        overlayColor: const Color(0xFF00668A).withOpacity(0.15),
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
    );
  }
}