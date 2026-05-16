import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpeedometerGauge extends StatefulWidget {
  final double speed;
  final double maxSpeed;

  const SpeedometerGauge({
    super.key,
    required this.speed,
    this.maxSpeed = 160,
  });

  @override
  State<SpeedometerGauge> createState() => _SpeedometerGaugeState();
}

class _SpeedometerGaugeState extends State<SpeedometerGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _prevSpeed = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: widget.speed).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(SpeedometerGauge old) {
    super.didUpdateWidget(old);
    if (old.speed != widget.speed) {
      _anim = Tween<double>(begin: _prevSpeed, end: widget.speed).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      );
      _prevSpeed = widget.speed;
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _SpeedometerPainter(
          speed: _anim.value,
          maxSpeed: widget.maxSpeed,
        ),
        child: SizedBox(
          width: 260,
          height: 260,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                Text(
                  _anim.value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const Text(
                  'KM/H',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 4,
                    color: Color(0xFFFF3B30),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;

  _SpeedometerPainter({required this.speed, required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Gradient speed arc
    final fraction = (speed / maxSpeed).clamp(0.0, 1.0);
    final arcColor = _arcColor(fraction);
    final speedPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * fraction,
        false,
        speedPaint,
      );
    }

    // Glow effect
    if (fraction > 0) {
      final glowPaint = Paint()
        ..color = arcColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * fraction,
        false,
        glowPaint,
      );
    }

    // Tick marks
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.5;
    for (int i = 0; i <= 8; i++) {
      final angle = startAngle + (sweepAngle / 8) * i;
      final outerPt = Offset(
        center.dx + (radius + 12) * math.cos(angle),
        center.dy + (radius + 12) * math.sin(angle),
      );
      final innerPt = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );
      canvas.drawLine(innerPt, outerPt, tickPaint);
    }
  }

  Color _arcColor(double fraction) {
    if (fraction < 0.5) return Color.lerp(Colors.greenAccent, Colors.amber, fraction * 2)!;
    return Color.lerp(Colors.amber, Colors.redAccent, (fraction - 0.5) * 2)!;
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) => old.speed != speed;
}
