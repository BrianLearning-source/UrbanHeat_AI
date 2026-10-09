import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  // Spacing scale: 8, 12, 16, 24, 32
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Layout paddings
  static const double screenPadding = 20.0;
  static const double cardPadding = 16.0;

  // Radii
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusFull = 999.0;

  // BorderRadius
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // Edge Insets
  static const EdgeInsets screenPaddingAll = EdgeInsets.symmetric(horizontal: screenPadding, vertical: md);
  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(horizontal: screenPadding);
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
}
