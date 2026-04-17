import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_morse_sounder/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.dark(
    primary: kAccent,
    secondary: kSecondaryText,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: kBackground,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    // ── Display / Headings — Space Grotesk (modern, geometric, balanced) ──
    displayLarge: GoogleFonts.outfit(
      fontSize: 48.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.0,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 36.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.05,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineLarge: GoogleFonts.outfit(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    // ── Body / Descriptions — DM Sans (clean, neutral) ────────────────────
    titleLarge: GoogleFonts.dmSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 15.sp,
      fontWeight: FontWeight.w300,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w300,
      color: kPrimaryText,
      height: 1.6,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12.sp,
      fontWeight: FontWeight.w300,
      color: kSecondaryText,
    ),
    // ── Labels / Identifiers — JetBrains Mono (circuit annotations) ──────
    labelLarge: GoogleFonts.jetBrainsMono(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.jetBrainsMono(
      fontSize: 11.sp,
      fontWeight: FontWeight.w500,
      color: kSecondaryText,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.jetBrainsMono(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
      letterSpacing: 0.3,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kPanelBg,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusCard),
      borderSide: const BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusCard),
      borderSide: const BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusCard),
      borderSide: const BorderSide(color: kAccent, width: kStrokeWeightMedium),
    ),
    hintStyle: GoogleFonts.jetBrainsMono(
      color: kSecondaryText,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.dmSans(
      color: kSecondaryText,
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
    ),
    floatingLabelStyle: GoogleFonts.dmSans(
      color: kAccent,
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: kBackground,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
      textStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        fontSize: 14.sp,
        letterSpacing: 0.5,
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    color: kPanelBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusCard)),
      side: BorderSide(color: kOutline, width: kStrokeWeight),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 0,
  ),
  useMaterial3: true,
);
