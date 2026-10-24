import 'package:flutter/material.dart';

class AppColors {
  // Official CareLink Brand Guidelines (from assets/images/COLORS.txt)
  static const Color brandNavy = Color(0xFF0D1638); // Navy ("Care", ring)
  static const Color primary = Color(0xFF18A795); // Teal (heart icon)
  static const Color primaryDark = Color(0xFF13897A); // Teal dark ("Link")
  static const Color primaryLight = Color(0xFFE8F8F5); // Fresh Mint tint
  static const Color secondary = Color(0xFF18A795);
  static const Color secondaryLight = Color(0xFFD6F5EE);

  // Status Colors
  static const Color online = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color badgeRed = Color(0xFFE11D48); // Red notification badge dot

  // Backgrounds & Canvas
  static const Color background = Color(0xFFF2FAF8); // Soft healthcare mint canvas
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color cardMintBg = Color(0xFFF4FBF9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0D1638); // Official Brand Navy
  static const Color textSecondary = Color(0xFF5A7184); // Mid slate-teal
  static const Color textMuted = Color(0xFF8FA2B0); // Subtle placeholder

  // Chat Bubble Colors
  static const Color userBubble = Color(0xFFE7F7F4); // Soft mint tinted bubble
  static const Color userBubbleBorder = Color(0xFFC4EFE6);
  static const Color botBubble = Colors.white; // Clean white card
  static const Color botIconBg = Color(0xFFE0F4EE); // Light teal circle
  static const Color bubbleBorder = Color(0xFFE2EDE9);

  // Borders & Dividers
  static const Color border = Color(0xFFE2ECEB);
  static const Color divider = Color(0xFFF0F5F4);

  // User Header Pill
  static const Color userPillBg = Color(0xFFE4F6F2);
  static const Color userPillIcon = Color(0xFF13897A);

  // Medicine Badge / Tag Colors
  static const Color tagBlueBg = Color(0xFFEFF6FF);
  static const Color tagBlueText = Color(0xFF1D4ED8);
  static const Color tagGreenBg = Color(0xFFF0FDF4);
  static const Color tagGreenText = Color(0xFF15803D);
  static const Color tagPurpleBg = Color(0xFFFAF5FF);
  static const Color tagPurpleText = Color(0xFF7E22CE);
}
