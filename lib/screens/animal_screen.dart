import 'package:flutter/material.dart';

import '../navigation.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'drawing_screen.dart';

//  SCREEN 4 — PICK YOUR ANIMAL

class _Animal {
  const _Animal(this.emoji, this.name);

  final String emoji;
  final String name;
}

const _animals = [
  _Animal('🐠', 'Fish'),
  _Animal('🐶', 'Dog'),
  _Animal('🦋', 'Butterfly'),
  _Animal('🐱', 'Cat'),
];

class AnimalScreen extends StatefulWidget {
  const AnimalScreen({super.key});

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  String _selected = 'Fish';

  Widget _card(_Animal animal) {
    return _AnimalCard(
      animal: animal,
      selected: _selected == animal.name,
      onTap: () => setState(() => _selected = animal.name),
    );
  }

  void _startDrawing() {
    final animal = _animals.firstWhere((a) => a.name == _selected);
    Navigator.of(context).push(
      fadeTo(DrawingScreen(animal: animal.name, emoji: animal.emoji)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SkyBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                RoundButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: const StrokeIcon(StrokeIcon.back, color: kNavy),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kPink,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kNavy, width: 2),
                        ),
                        child: const Label(
                          '🐶 Animal',
                          size: 13,
                          color: Colors.white,
                          weight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const StickerText('Pick your animal', size: 22),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const HintPill('Which animal will you draw?'),
            const SizedBox(height: 10),

            // 2 x 2 grid of animals
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 10, bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _card(_animals[0])),
                        const SizedBox(width: 18),
                        Expanded(child: _card(_animals[1])),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _card(_animals[2])),
                        const SizedBox(width: 18),
                        Expanded(child: _card(_animals[3])),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Start button
            FractionallySizedBox(
              widthFactor: 0.78,
              child: SizedBox(
                height: 70,
                child: ChunkyCard(
                  color: kYellow,
                  radius: 35,
                  depth: 6,
                  alignment: Alignment.center,
                  onTap: _startDrawing,
                  child: const Label(
                    '✏️ Start drawing',
                    size: 22,
                    weight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 52),
          ],
        ),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.selected,
    required this.onTap,
  });

  final _Animal animal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ChunkyCard(
            color: selected ? kPinkSoft : Colors.white,
            borderColor: selected ? kPink : kNavy,
            shadowColor: selected ? kPink : kNavy,
            radius: 22,
            depth: 7,
            alignment: Alignment.center,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Emoji(animal.emoji, size: 60),
                    Label(animal.name, size: 22, weight: FontWeight.w900),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (selected)
          const Positioned(top: -6, right: 0, child: _CheckBadge()),
      ],
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kGreen,
        shape: BoxShape.circle,
        border: Border.all(color: kNavy, width: 3),
      ),
      child: const StrokeIcon(StrokeIcon.check, color: Colors.white, size: 13),
    );
  }
}