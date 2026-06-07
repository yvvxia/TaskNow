import 'package:flutter/material.dart';

/// Paints vertical day gridlines for the week/Gantt timelines.
class TimelineGridPainter extends CustomPainter {
  TimelineGridPainter({
    required this.dayCount,
    required this.pxPerDay,
    required this.lineColor,
    this.weekendShade,
    this.firstWeekday = DateTime.monday,
  });

  final int dayCount;
  final double pxPerDay;
  final Color lineColor;
  final Color? weekendShade;
  final int firstWeekday;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (var i = 0; i <= dayCount; i++) {
      final x = i * pxPerDay;
      if (weekendShade != null && i < dayCount) {
        final weekday = ((firstWeekday - 1 + i) % 7) + 1;
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          canvas.drawRect(
            Rect.fromLTWH(x, 0, pxPerDay, size.height),
            Paint()..color = weekendShade!,
          );
        }
      }
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
  }

  @override
  bool shouldRepaint(covariant TimelineGridPainter oldDelegate) =>
      oldDelegate.dayCount != dayCount ||
      oldDelegate.pxPerDay != pxPerDay ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.weekendShade != weekendShade;
}
