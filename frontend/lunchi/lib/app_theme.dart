import 'package:flutter/material.dart';

// ─── Primary Blues ────────────────────────────────────────────────────────────
const kNavy       = Color(0xFF1A2E6E);
const kPrimaryBlue = Color(0xFF1A3A8F);
const kAccentBlue  = Color(0xFF2563EB);
const kSky         = Color(0xFF3A8DE0);
const kBlue        = Color(0xFF1E5CBF);

// ─── Backgrounds & Surfaces ──────────────────────────────────────────────────
const kBgColor    = Color(0xFFEAF2FF);
const kCardWhite  = Color(0xFFFFFFFF);
const kLightBlue  = Color(0xFFDBE9FF);
const kPillBg     = Color(0xFFEEF4FF);
const kSubtle     = Color(0xFFF0F5FB);

// ─── Text ────────────────────────────────────────────────────────────────────
const kSubtext    = Color(0xFF5A7CC9);
const kGray       = Color(0xFF8A96A8);
const kDarkText   = Color(0xFF1A2340);

// ─── Borders & Dividers ──────────────────────────────────────────────────────
const kBorder     = Color(0xFFDCE8F5);

// ─── Status Colors ───────────────────────────────────────────────────────────
const kGreen      = Color(0xFF1A7A4E);
const kGreenLight = Color(0xFF22A66A);
const kRed        = Color(0xFFE02020);
const kRedAccent  = Color(0xFFE53935);

// ─── Gradients ───────────────────────────────────────────────────────────────
const kPageGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFC5D9EF), Color(0xFFD8E9F7), Color(0xFFBCD2E9)],
);

const kLoginCardShadow = [
  BoxShadow(
    color: Color(0x2E1A2E6E), // kNavy 18%
    blurRadius: 60,
    offset: Offset(0, 24),
  ),
  BoxShadow(
    color: Color(0x141A2E6E), // kNavy 8%
    blurRadius: 20,
    offset: Offset(0, 6),
  ),
];

// ─── Shared Card Decoration ──────────────────────────────────────────────────
BoxDecoration kCardDecoration({double radius = 18}) => BoxDecoration(
  color: kCardWhite,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: kPrimaryBlue.withOpacity(0.07),
      blurRadius: 14,
      offset: const Offset(0, 3),
    ),
  ],
);

// ─── Shared Pill Decoration ──────────────────────────────────────────────────
BoxDecoration kPillDecoration({Color? color}) => BoxDecoration(
  color: color ?? kPillBg,
  borderRadius: BorderRadius.circular(10),
  border: Border.all(color: kBorder),
);
