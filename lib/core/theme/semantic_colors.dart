import 'package:flutter/material.dart';

/// Semantic color constants shared across the app.
/// Used for task priority indicators, status badges, and Gantt bar colours
/// (proposal §5.5). Centralised here so every feature references the same values.
abstract final class SemanticColors {
  // ── Priority ─────────────────────────────────────────────────────────────

  /// High-priority indicator: red.
  static const Color priorityHigh = Color(0xFFE53935);

  /// Medium-priority indicator: orange.
  static const Color priorityMedium = Color(0xFFFF9800);

  /// Low-priority indicator: green.
  static const Color priorityLow = Color(0xFF43A047);

  // ── Task state ────────────────────────────────────────────────────────────

  /// Overdue task: deep orange-red.
  static const Color overdue = Color(0xFFD32F2F);

  /// Completed task: grey.
  static const Color complete = Color(0xFF9E9E9E);

  // ── Primary brand colour ──────────────────────────────────────────────────

  /// Brand seed / primary blue (proposal §5.5 `#1976D2`).
  static const Color primary = Color(0xFF1976D2);
}
