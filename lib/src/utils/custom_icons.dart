import 'package:flutter/material.dart';

/// Custom eye icons for password visibility
class CustomEyeIcon extends StatelessWidget {
  /// Whether the eye is open (password visible)
  final bool isVisible;

  /// Color of the icon
  final Color? color;

  /// Size of the icon
  final double size;

  /// Custom eye icon for password visibility toggle
  const CustomEyeIcon({
    super.key,
    required this.isVisible,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).iconTheme.color;

    if (isVisible) {
      // Eye open icon (password visible)
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _EyeOpenPainter(color: iconColor),
        ),
      );
    } else {
      // Eye closed icon (password hidden)
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _EyeClosedPainter(color: iconColor),
        ),
      );
    }
  }
}

/// Painter for the eye open icon
class _EyeOpenPainter extends CustomPainter {
  final Color? color;

  _EyeOpenPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw eye outline
    final eyePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.9,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.9,
        size.width * 0.1,
        size.height * 0.5,
      );

    canvas.drawPath(eyePath, paint);

    // Draw pupil
    final pupilPaint = Paint()
      ..color = color ?? Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.15,
      pupilPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for the eye closed icon
class _EyeClosedPainter extends CustomPainter {
  final Color? color;

  _EyeClosedPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw eye outline (slightly closed)
    final eyePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.7,
        size.width * 0.9,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width * 0.1,
        size.height * 0.5,
      );

    canvas.drawPath(eyePath, paint);

    // Draw slash through eye
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
