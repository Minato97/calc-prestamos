import 'dart:math';

import 'package:flutter/material.dart';

import 'finance.dart';

const kTeal = Color(0xFF14B8A6);
const kBlue = Color(0xFF1D4ED8);
const kGold = Color(0xFFF59E0B);

/// Cabecera con degradado, ilustración y resumen.
class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kBlue, kTeal],
        ),
        boxShadow: [
          BoxShadow(
            color: kBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset('assets/icon.png', width: 72, height: 72),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de resultado principal con degradado.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.label,
    required this.value,
    this.footnote,
  });

  final String label;
  final String value;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: scheme.primaryContainer,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 6),
            Text(footnote!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  const LegendDot(this.color, this.text, {super.key});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

/// Anillo capital vs. intereses.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.principal,
    required this.interest,
  });

  final double principal;
  final double interest;

  @override
  Widget build(BuildContext context) {
    final total = principal + interest;
    final pct = total == 0 ? 0 : interest / total * 100;
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _DonutPainter(
              principal: principal,
              interest: interest,
              track: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'intereses',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LegendDot(kBlue, 'Capital ${pesos(principal, decimals: 0)}'),
              const SizedBox(height: 10),
              LegendDot(kGold, 'Intereses ${pesos(interest, decimals: 0)}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.principal,
    required this.interest,
    required this.track,
  });

  final double principal;
  final double interest;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(arc, 0, 2 * pi, false, paint..color = track);
    final total = principal + interest;
    if (total <= 0) return;
    final sweepP = 2 * pi * principal / total;
    canvas.drawArc(arc, -pi / 2, sweepP, false, paint..color = kBlue);
    canvas.drawArc(
      arc,
      -pi / 2 + sweepP,
      2 * pi - sweepP,
      false,
      paint..color = kGold,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.principal != principal || old.interest != interest;
}

class Series {
  const Series(this.values, this.color, this.label);

  final List<double> values;
  final Color color;
  final String label;
}

/// Líneas con área suave para saldo o ahorro por mes.
class LineChart extends StatelessWidget {
  const LineChart({super.key, required this.series, this.height = 160});

  final List<Series> series;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _LinePainter(
              series,
              Theme.of(context).colorScheme.outlineVariant,
              Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [for (final s in series) LegendDot(s.color, s.label)],
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.series, this.grid, this.textColor);

  final List<Series> series;
  final Color grid;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || series.first.values.length < 2) return;
    final maxV = series
        .expand((s) => s.values)
        .fold<double>(0, (m, v) => max(m, v));
    if (maxV <= 0) return;
    const left = 0.0, bottom = 4.0;
    final w = size.width - left;
    final h = size.height - bottom;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = h * i / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
    }
    for (final s in series) {
      final n = s.values.length;
      final path = Path();
      final area = Path();
      for (var i = 0; i < n; i++) {
        final x = left + w * i / (n - 1);
        final y = h - h * s.values[i] / maxV;
        if (i == 0) {
          path.moveTo(x, y);
          area.moveTo(x, h);
          area.lineTo(x, y);
        } else {
          path.lineTo(x, y);
          area.lineTo(x, y);
        }
      }
      area.lineTo(size.width, h);
      area.close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              s.color.withValues(alpha: 0.30),
              s.color.withValues(alpha: 0.0),
            ],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}

/// Contenedor de sección con título.
class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
