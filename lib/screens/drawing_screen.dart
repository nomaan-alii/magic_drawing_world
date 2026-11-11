import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/drawing_helpers.dart';

//  SCREEN 5 — DRAW YOUR ANIMAL

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({
    super.key,
    required this.animal,
    required this.emoji,
  });

  final String animal;
  final String emoji;

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

/// One finger line on the paper.
class _Stroke {
  _Stroke(this.color, this.width, this.eraser, Offset start) : points = [start];

  final Color color;
  final double width;
  final bool eraser;
  final List<Offset> points;
}

const _palette = [
  kNavy,
  kPink,
  Color(0xFFE53935), // red
  kOrange,
  kYellow,
  kGreen,
  kSky,
  kPurple,
  Color(0xFF8D5524), // brown
];

const _brushSizes = [6.0, 12.0, 22.0];

class _DrawingScreenState extends State<DrawingScreen> {
  final List<_Stroke> _strokes = [];

  Color _color = kPink;
  double _brush = 12;
  bool _eraser = false;

  void _start(Offset point) {
    setState(() {
      _strokes.add(
        _Stroke(_color, _eraser ? _brush * 2 : _brush, _eraser, point),
      );
    });
  }

  void _move(Offset point) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.points.add(point));
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _clear() {
    setState(() => _strokes.clear());
  }

  void _finish() {
    final hasInk = _strokes.any((stroke) => !stroke.eraser);

    if (!hasInk) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Draw something first!'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ChunkyCard(
            color: kPurple,
            radius: 28,
            depth: 8,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Emoji('⭐⭐⭐', size: 40),
                  const SizedBox(height: 8),
                  const StickerText(
                    'Great job!',
                    size: 32,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Label(
                    'You drew a ${widget.animal} ${widget.emoji}',
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ChunkyCard(
                          radius: 22,
                          depth: 5,
                          alignment: Alignment.center,
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                            _clear();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Label(
                              '🔄 Again',
                              size: 16,
                              weight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChunkyCard(
                          color: kYellow,
                          radius: 22,
                          depth: 5,
                          alignment: Alignment.center,
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Label(
                              '🏠 Home',
                              size: 16,
                              weight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SkyBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Back button, title and Done
            Row(
              children: [
                RoundButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: const StrokeIcon(StrokeIcon.back, color: kNavy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StickerText('Draw a ${widget.animal}!', size: 22),
                ),
                ChunkyCard(
                  color: kYellow,
                  radius: 24,
                  depth: 5,
                  onTap: _finish,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Label('✅ Done', size: 16, weight: FontWeight.w900),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            HintPill(
              'Trace the dotted ${widget.animal.toLowerCase()} ${widget.emoji}',
            ),
            const SizedBox(height: 12),

            // The paper
            Expanded(
              child: ChunkyCard(
                radius: 24,
                depth: 7,
                child: SizedBox.expand(
                  child: GestureDetector(
                    onPanStart: (details) => _start(details.localPosition),
                    onPanUpdate: (details) => _move(details.localPosition),
                    child: CustomPaint(
                      painter: _DrawingPainter(widget.animal, _strokes),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Colours
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _palette.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final color = _palette[index];
                  final selected = !_eraser && color == _color;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _color = color;
                      _eraser = false;
                    }),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: selected ? 44 : 36,
                        height: selected ? 44 : 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : kNavy,
                            width: selected ? 4 : 3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Brush sizes, eraser, undo, clear
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final size in _brushSizes)
                  _ToolButton(
                    selected: !_eraser && _brush == size,
                    onTap: () => setState(() {
                      _brush = size;
                      _eraser = false;
                    }),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: _color,
                        shape: BoxShape.circle,
                        border: Border.all(color: kNavy, width: 1.5),
                      ),
                    ),
                  ),
                _ToolButton(
                  selected: _eraser,
                  onTap: () => setState(() => _eraser = !_eraser),
                  child: const Emoji('🧽', size: 22),
                ),
                _ToolButton(
                  onTap: _undo,
                  child: const Emoji('↩️', size: 22),
                ),
                _ToolButton(
                  onTap: _clear,
                  child: const Emoji('🗑️', size: 22),
                ),
              ],
            ),

            // Space above the grass
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.onTap,
    required this.child,
    this.selected = false,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ChunkyCard(
      color: selected ? kYellow : Colors.white,
      radius: 24,
      depth: 4,
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Center(child: child),
      ),
    );
  }
}

// PAINTER: dotted guide underneath, the child's lines on top

class _DrawingPainter extends CustomPainter {
  _DrawingPainter(this.animal, this.strokes);

  final String animal;
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    // Dotted guide, drawn on a 300 x 300 grid and centred.
    const grid = 300.0;
    final s = math.min(size.width, size.height) / grid * 0.9;

    canvas.save();
    canvas.translate(
      (size.width - grid * s) / 2,
      (size.height - grid * s) / 2,
    );
    canvas.scale(s);
    canvas.drawPath(
      dashedPath(_outline(animal), 10, 8),
      Paint()
        ..color = const Color(0xFFC9BDF2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // Lines go on their own layer so the eraser only removes ink,
    // never the dotted guide.
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..blendMode = stroke.eraser ? BlendMode.clear : BlendMode.srcOver;

      if (stroke.points.length == 1) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(stroke.points.first, stroke.width / 2, paint);
      } else {
        final path = Path()
          ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (final point in stroke.points.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawPath(path, paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

// ANIMAL OUTLINES (300 x 300 grid)

Path _outline(String animal) {
  switch (animal) {
    case 'Dog':
      return _dogOutline();
    case 'Butterfly':
      return _butterflyOutline();
    case 'Cat':
      return _catOutline();
    default:
      return _fishOutline();
  }
}

Path _fishOutline() {
  // Same fish shape as the splash screen, plus an eye and a gill.
  return fishPath(40, 150, 230)
    ..addOval(Rect.fromCircle(center: const Offset(86, 132), radius: 9))
    ..moveTo(112, 112)
    ..quadraticBezierTo(132, 150, 112, 188);
}

Path _catOutline() {
  return Path()
    ..addOval(Rect.fromCircle(center: const Offset(150, 170), radius: 85))
    ..moveTo(82, 125)
    ..lineTo(92, 48)
    ..lineTo(138, 88)
    ..moveTo(162, 88)
    ..lineTo(208, 48)
    ..lineTo(218, 125)
    ..addOval(Rect.fromCircle(center: const Offset(120, 160), radius: 10))
    ..addOval(Rect.fromCircle(center: const Offset(180, 160), radius: 10))
    ..moveTo(142, 188)
    ..lineTo(158, 188)
    ..lineTo(150, 198)
    ..close()
    ..moveTo(150, 198)
    ..quadraticBezierTo(140, 214, 128, 207)
    ..moveTo(150, 198)
    ..quadraticBezierTo(160, 214, 172, 207)
    ..moveTo(108, 192)
    ..lineTo(68, 185)
    ..moveTo(108, 202)
    ..lineTo(70, 210)
    ..moveTo(192, 192)
    ..lineTo(232, 185)
    ..moveTo(192, 202)
    ..lineTo(230, 210);
}

Path _dogOutline() {
  return Path()
    ..addOval(
      Rect.fromCenter(center: const Offset(150, 160), width: 160, height: 170),
    )
    ..addOval(const Rect.fromLTWH(40, 85, 50, 115))
    ..addOval(const Rect.fromLTWH(210, 85, 50, 115))
    ..addOval(Rect.fromCircle(center: const Offset(120, 145), radius: 9))
    ..addOval(Rect.fromCircle(center: const Offset(180, 145), radius: 9))
    ..addOval(
      Rect.fromCenter(center: const Offset(150, 200), width: 80, height: 56),
    )
    ..addOval(
      Rect.fromCenter(center: const Offset(150, 186), width: 28, height: 18),
    )
    ..moveTo(150, 195)
    ..lineTo(150, 212);
}

Path _butterflyOutline() {
  return Path()
    ..addOval(
      Rect.fromCenter(center: const Offset(150, 155), width: 24, height: 150),
    )
    ..addOval(
      Rect.fromCenter(center: const Offset(95, 115), width: 100, height: 90),
    )
    ..addOval(
      Rect.fromCenter(center: const Offset(205, 115), width: 100, height: 90),
    )
    ..addOval(
      Rect.fromCenter(center: const Offset(105, 200), width: 70, height: 70),
    )
    ..addOval(
      Rect.fromCenter(center: const Offset(195, 200), width: 70, height: 70),
    )
    ..moveTo(145, 82)
    ..quadraticBezierTo(130, 50, 115, 45)
    ..moveTo(155, 82)
    ..quadraticBezierTo(170, 50, 185, 45);
}