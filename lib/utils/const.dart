import 'package:flutter/material.dart';
import 'package:the_morse_sounder/enum/my_enums.dart';

// ─── COLOR PALETTE — "Signal & Silence" ──────────────────────────────────────
const Color kBackground    = Color(0xFF0D0D0D); // Transmission black
const Color kPrimaryText   = Color(0xFFF0EDE8); // Warm off-white (paper tape)
const Color kPanelBg       = Color(0xFF161616); // Secondary panels / cards
const Color kSecondaryText = Color(0xFF5A5A5A); // Muted labels
const Color kAccent        = Color(0xFFE8C547); // Sounder gold (brass armature)
const Color kOutline       = Color(0xFF242424); // Dividers / strokes
const Color kError         = Color(0xFFC0392B); // Critical errors only

// ─── DERIVED COLORS ──────────────────────────────────────────────────────────
const Color kAccentDim     = Color(0xFFB89A30); // Dimmed gold for icons
const Color kAccentSurface = Color(0xFF141400); // Gold-tinted dark surface
const Color kGlassBg       = Color(0x99161616); // Translucent panel

// ─── SPACING ─────────────────────────────────────────────────────────────────
const double kSpacingXXS  = 4.0;
const double kSpacingXS   = 8.0;
const double kSpacingS    = 12.0;
const double kSpacingM    = 16.0;
const double kSpacingL    = 20.0;
const double kSpacingXL   = 24.0;
const double kSpacingXXL  = 32.0;
const double kSpacingXXXL = 48.0;

// ─── BORDER RADIUS ───────────────────────────────────────────────────────────
const double kRadiusZero     = 0.0;
const double kRadiusCard     = 10.0;
const double kRadiusSubtle   = 10.0;
const double kRadiusStandard = 10.0;
const double kRadiusMedium   = 14.0;
const double kRadiusLarge    = 20.0;
const double kRadiusXLarge   = 24.0;
const double kRadiusPill     = 999.0;

// ─── SHADOWS ─────────────────────────────────────────────────────────────────
const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: -4,
  color: Color(0x40000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 32,
  spreadRadius: -8,
  color: Color(0x60000000),
);

const BoxShadow kShadowGold = BoxShadow(
  offset: Offset(0, 6),
  blurRadius: 20,
  spreadRadius: -4,
  color: Color(0x40E8C547),
);

const double kStrokeWeight       = 1.0;
const double kStrokeWeightMedium = 1.5;

// ─── SOUNDER TYPE BADGE COLORS ────────────────────────────────────────────────
Color getSounderTypeColor(SounderType type) {
  switch (type) {
    case SounderType.towerSounder:
      return kAccent;
    case SounderType.mainSounder:
      return const Color(0xFF4A8FAA);
    case SounderType.relaySounder:
      return const Color(0xFF7A8A95);
    case SounderType.portableSounder:
      return const Color(0xFF7A6A3A);
    case SounderType.galvanometricReceiver:
      return const Color(0xFF6A4A8A);
  }
}

// ─── CONDITION COLORS ────────────────────────────────────────────────────────
Color getConditionColor(ConditionState state) {
  switch (state) {
    case ConditionState.pristine:
      return kAccent;
    case ConditionState.functional:
      return const Color(0xFF4A8F6A);
    case ConditionState.corroded:
      return kError;
    case ConditionState.coilDamaged:
      return const Color(0xFFB07D2A);
    case ConditionState.incomplete:
      return const Color(0xFF8C6B3A);
    case ConditionState.unknown:
      return kSecondaryText;
  }
}

// ─── MATERIAL COLORS ─────────────────────────────────────────────────────────
Color getMaterialColor(ManufacturingMaterial mat) {
  switch (mat) {
    case ManufacturingMaterial.brass:
      return const Color(0xFFB8963A);
    case ManufacturingMaterial.castIron:
      return const Color(0xFF4A4A4A);
    case ManufacturingMaterial.steel:
      return const Color(0xFF7A8A95);
    case ManufacturingMaterial.copper:
      return const Color(0xFFB05A30);
    case ManufacturingMaterial.ebony:
      return const Color(0xFF2A1A0A);
    case ManufacturingMaterial.wood:
      return const Color(0xFF6A4A2A);
    case ManufacturingMaterial.mixed:
      return const Color(0xFF5A5A6A);
  }
}

// ─── ARMATURE COLORS ─────────────────────────────────────────────────────────
Color getArmatureColor(ArmatureType type) {
  switch (type) {
    case ArmatureType.straight:
      return const Color(0xFF7A8A95);
    case ArmatureType.lShaped:
      return kAccent;
    case ArmatureType.doubleLever:
      return const Color(0xFF4A8FAA);
    case ArmatureType.balanced:
      return const Color(0xFF6A4A8A);
  }
}
