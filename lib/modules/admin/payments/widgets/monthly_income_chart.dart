import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/dashboard_stats_model.dart';

class MonthlyIncomeChart extends StatefulWidget {
  final List<IncomePoint> points;
  final String title;
  const MonthlyIncomeChart({
    super.key,
    required this.points,
    this.title = 'Monthly Revenue',
  });

  @override
  State<MonthlyIncomeChart> createState() => _MonthlyIncomeChartState();
}

class _MonthlyIncomeChartState extends State<MonthlyIncomeChart> {
  static const double _height = 230;
  int? _selected;

  void _pick(double dx, double width) {
    final n = widget.points.length;
    if (n == 0) return;
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < n; i++) {
      final d = (dx - _ChartPainter.xAt(i, n, width)).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    if (best != _selected) setState(() => _selected = best);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _Scale.from(widget.points.map((p) => p.value).toList());

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppTextStyles.sectionInnerTitle),
          const SizedBox(height: AppSizes.md),
          if (widget.points.isEmpty)
            const SizedBox(
                height: _height, child: Center(child: Text('No data yet')))
          else
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => _pick(d.localPosition.dx, w),
                  onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx, w),
                  child: CustomPaint(
                    size: Size(w, _height),
                    painter: _ChartPainter(
                      points: widget.points,
                      scale: scale,
                      selected: _selected,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// "Nice" axis: 0, 2.5k, 5k, 7.5k, 10k ya 0, 50k, 100k ... (hamesha 4 intervals)
class _Scale {
  final double max;
  final double step;
  const _Scale(this.max, this.step);

  factory _Scale.from(List<double> values) {
    final peak = values.isEmpty ? 0.0 : values.reduce(math.max);
    if (peak <= 0) return const _Scale(4000, 1000);

    final raw = peak / 4;
    final exp = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final f = raw / exp;
    final nice = f <= 1 ? 1 : f <= 2 ? 2 : f <= 2.5 ? 2.5 : f <= 5 ? 5 : 10;
    final step = nice * exp;
    return _Scale(step * 4, step);
  }
}

class _ChartPainter extends CustomPainter {
  final List<IncomePoint> points;
  final _Scale scale;
  final int? selected;

  _ChartPainter({
    required this.points,
    required this.scale,
    required this.selected,
  });

  static const double left = 44, right = 16, top = 44, bottom = 28;
  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFFC026D3);

  static double xAt(int i, int n, double width) {
    final w = width - left - right;
    return n == 1 ? left + w / 2 : left + w * i / (n - 1);
  }

  Offset _pos(int i, Size size) {
    final h = size.height - top - bottom;
    final ratio = (points[i].value / scale.max).clamp(0.0, 1.0).toDouble();
    return Offset(xAt(i, points.length, size.width), top + h * (1 - ratio));
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  String _axis(double v) {
    if (v >= 1000000) return '${_trim(v / 1000000)}M';
    if (v >= 1000) return '${_trim(v / 1000)}k';
    return _trim(v);
  }

  String _money(double v) => v
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  TextPainter _text(String s, TextStyle style) => TextPainter(
    text: TextSpan(text: s, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - top - bottom;
    const axisStyle = TextStyle(fontSize: 11, color: Color(0xFF6B7280));

    // Grid + y labels
    final grid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (var t = 0; t <= 4; t++) {
      final y = top + h * (1 - t / 4);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), grid);
      final tp = _text(_axis(scale.step * t), axisStyle);
      tp.paint(canvas, Offset(left - 8 - tp.width, y - tp.height / 2));
    }

    // x labels
    for (var i = 0; i < points.length; i++) {
      final tp = _text(points[i].label, axisStyle);
      final x = xAt(i, points.length, size.width);
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottom + 8));
    }

    final pos = [for (var i = 0; i < points.length; i++) _pos(i, size)];

    // Curve: horizontal tangents => kabhi min/max se bahar nahi jati
    if (pos.length > 1) {
      final path = Path()..moveTo(pos.first.dx, pos.first.dy);
      for (var i = 1; i < pos.length; i++) {
        final a = pos[i - 1], b = pos[i];
        final mid = (a.dx + b.dx) / 2;
        path.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
      }
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          Offset(left, 0),
          Offset(size.width - right, 0),
          [_blue, _purple],
        );
      canvas.drawPath(path, line);
    }

    // Selected: dashed guide
    if (selected != null && selected! < pos.length) {
      final p = pos[selected!];
      final dash = Paint()
        ..color = const Color(0xFF9CA3AF)
        ..strokeWidth = 1.5;
      for (var y = p.dy; y < size.height - bottom; y += 7) {
        canvas.drawLine(
            Offset(p.dx, y), Offset(p.dx, math.min(y + 3, size.height - bottom)), dash);
      }
    }

    // Dots
    for (var i = 0; i < pos.length; i++) {
      canvas.drawCircle(pos[i], 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        pos[i],
        5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = _purple,
      );
    }

    // Tooltip
    if (selected != null && selected! < pos.length) {
      final p = pos[selected!];
      final title = _text('Revenue',
          const TextStyle(fontSize: 10, color: Color(0xCCFFFFFF)));
      final value = _text(
        _money(points[selected!].value),
        const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      );
      final w = math.max(title.width, value.width) + 24;
      const hBox = 44.0;
      var x = p.dx - w / 2;
      x = x.clamp(0.0, size.width - w).toDouble();
      var y = p.dy - hBox - 10;
      if (y < 0) y = p.dy + 12;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, hBox), const Radius.circular(10)),
        Paint()..color = const Color(0xFF111827),
      );
      title.paint(canvas, Offset(x + (w - title.width) / 2, y + 6));
      value.paint(canvas, Offset(x + (w - value.width) / 2, y + 20));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.points != points || old.selected != selected || old.scale.max != scale.max;
}