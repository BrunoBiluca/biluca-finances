import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RoundedRectDotPainter extends FlDotPainter {
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final double width;
  final double height;
  final double radius;
  final BorderRadius? borderRadius;

  RoundedRectDotPainter({
    this.color = Colors.blue,
    this.borderColor,
    this.borderWidth = 0,
    this.width = 10.0,
    this.height = 10.0,
    this.radius = 4.0,
    this.borderRadius,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    // Define o retângulo ao redor do centro do ponto
    final rect = Rect.fromCenter(
      center: offsetInCanvas,
      width: width,
      height: height,
    );

    // Cria o RRect com cantos arredondados
    final rrect =
        borderRadius != null ? borderRadius!.toRRect(rect) : RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Preenchimento
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Borda (opcional)
    if (borderColor != null && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  Size getSize(FlSpot spot) {
    // Inclui a largura da borda no tamanho total
    return Size(
      width + borderWidth,
      height + borderWidth,
    );
  }

  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is RoundedRectDotPainter && b is RoundedRectDotPainter) {
      return RoundedRectDotPainter(
        color: Color.lerp(a.color, b.color, t) ?? a.color,
        borderColor: Color.lerp(a.borderColor, b.borderColor, t),
        borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t) ?? a.borderWidth,
        width: lerpDouble(a.width, b.width, t) ?? a.width,
        height: lerpDouble(a.height, b.height, t) ?? a.height,
        radius: lerpDouble(a.radius, b.radius, t) ?? a.radius,
        borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      );
    }
    return this;
  }

  @override
  List<Object?> get props => [
        color,
        borderColor,
        borderWidth,
        width,
        height,
        radius,
        borderRadius,
      ];
}
