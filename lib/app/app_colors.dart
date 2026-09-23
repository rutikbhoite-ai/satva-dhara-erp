import 'package:flutter/material.dart';

/// SATVA DHARA ERP
/// Centralized color system for the complete application.
///
/// IMPORTANT:
/// All screens should use these colors instead of creating
/// random colors repeatedly.
class AppColors {
  AppColors._();

  // ============================================================
  // BRAND COLORS
  // ============================================================

  /// Main farm / agriculture green.
  static const Color primary = Color(0xFF2E7D32);

  /// Darker green for gradients, headers and emphasis.
  static const Color primaryDark = Color(0xFF1B5E20);

  /// Lighter green for subtle backgrounds.
  static const Color primaryLight = Color(0xFFE8F5E9);

  /// Milk / dairy blue.
  static const Color secondary = Color(0xFF0288D1);

  /// Light blue background.
  static const Color secondaryLight = Color(0xFFE1F5FE);

  // ============================================================
  // BACKGROUND & SURFACE
  // ============================================================

  static const Color background = Color(0xFFF5F7F6);

  static const Color surface = Color(0xFFFFFFFF);

  static const Color surfaceVariant = Color(0xFFF0F3F1);

  static const Color divider = Color(0xFFE2E7E4);

  // ============================================================
  // TEXT
  // ============================================================

  static const Color textPrimary = Color(0xFF212121);

  static const Color textSecondary = Color(0xFF616161);

  static const Color textTertiary = Color(0xFF8A8F8C);

  static const Color textOnPrimary = Colors.white;

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color success = Color(0xFF2E7D32);

  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF57C00);

  static const Color warningLight = Color(0xFFFFF3E0);

  static const Color error = Color(0xFFD32F2F);

  static const Color errorLight = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF1976D2);

  static const Color infoLight = Color(0xFFE3F2FD);

  // ============================================================
  // FEATURE COLORS
  // ============================================================

  /// Animal related UI.
  static const Color animal = Color(0xFFF57C00);

  /// Milk related UI.
  static const Color milk = Color(0xFF0288D1);

  /// Expense related UI.
  static const Color expense = Color(0xFFD32F2F);

  /// Inventory related UI.
  static const Color inventory = Color(0xFF00897B);

  /// Health related UI.
  static const Color health = Color(0xFF43A047);

  /// Pregnancy / breeding related UI.
  static const Color pregnancy = Color(0xFFD81B60);

  /// Reports related UI.
  static const Color reports = Color(0xFF7B1FA2);

  // ============================================================
  // SYNC STATUS
  // ============================================================

  static const Color synced = Color(0xFF2E7D32);

  static const Color syncing = Color(0xFF1976D2);

  static const Color offline = Color(0xFFF57C00);

  static const Color syncError = Color(0xFFD32F2F);

  // ============================================================
  // SPECIAL
  // ============================================================

  static const Color shadow = Color(0x14000000);

  static const Color overlay = Color(0x66000000);
}