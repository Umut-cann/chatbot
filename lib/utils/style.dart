import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modern gradient colors
const Color primary = Color(0xFF667EEA);
const Color secondary = Color(0xFF764BA2);
const Color accent = Color(0xFFFF6B6B);
const Color backgroundDark = Color(0xFF0A0A0A);
const Color backgroundLight = Color(0xFF1A1A1A);
const Color surfaceColor = Color(0xFF2A2A2A);
const Color glassColor = Color(0x20FFFFFF);
const Color userChatGradientStart = Color(0xFF667EEA);
const Color userChatGradientEnd = Color(0xFF764BA2);
const Color aiChatGradientStart = Color(0xFF43E97B);
const Color aiChatGradientEnd = Color(0xFF38F9D7);
const Color white = Color(0xFFFFFFFF);
const Color greyLight = Color(0xFFB0B0B0);
const Color greyDark = Color(0xFF6A6A6A);

// Gradients
const LinearGradient backgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [backgroundDark, backgroundLight],
);

const LinearGradient userChatGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [userChatGradientStart, userChatGradientEnd],
);

const LinearGradient aiChatGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [aiChatGradientStart, aiChatGradientEnd],
);

const LinearGradient sendButtonGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [primary, secondary],
);

// Text Styles
TextStyle get appBarTitle => GoogleFonts.inter(
  color: white,
  fontSize: 24,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.5,
);

TextStyle get messageText => GoogleFonts.inter(
  color: white,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.4,
);

TextStyle get hintText => GoogleFonts.inter(
  color: greyDark,
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

TextStyle get dateText => GoogleFonts.inter(
  color: greyLight,
  fontSize: 12,
  fontWeight: FontWeight.w500,
);

TextStyle get promptText =>
    GoogleFonts.inter(color: white, fontSize: 16, fontWeight: FontWeight.w400);
