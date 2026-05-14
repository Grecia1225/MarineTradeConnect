import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';

class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp      = Provider.of<ThemeProvider>(context);
    final current = tp.current;

    return Scaffold(
      backgroundColor: current.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _BgPainter(current)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: current.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: current.primary.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white70, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Choose your vibe',
                            style: TextStyle(color: Colors.white,
                                fontSize: 20, fontWeight: FontWeight.w800)),
                        Text('Personalise your experience',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12)),
                      ],
                    ),
                  ]),
                ),

                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    itemCount: tp.themes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final theme      = tp.themes[index];
                      final isSelected = tp.currentThemeId == theme.id;

                      return GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            tp.setTheme(theme.id);
                            HapticFeedback.lightImpact();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primary
                                  : Colors.white.withOpacity(0.08),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Stack(children: [

                              // Zero-data theme preview art
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _ThemeCardPainter(
                                      theme, isSelected),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Row(children: [
                                  Container(
                                    width: 52, height: 52,
                                    decoration: BoxDecoration(
                                      color: theme.primary.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.primary.withOpacity(0.5),
                                          width: 2),
                                    ),
                                    child: Center(
                                      child: Text(theme.emoji,
                                          style: const TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(theme.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Row(children: [
                                          _dot(theme.background),
                                          _dot(theme.primary),
                                          _dot(theme.card),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 26, height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? theme.primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.primary
                                            : Colors.white24,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            size: 14, color: Colors.black)
                                        : null,
                                  ),
                                ]),
                              ),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        margin: const EdgeInsets.only(right: 4),
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
      );
}

// ── Full page background painter ──────────────────────────────────────────────
class _BgPainter extends CustomPainter {
  final AppTheme t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = t.background);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          colors: [t.primary.withOpacity(0.08), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(size.width, 0), radius: size.height * 0.6)),
    );

    final linePaint = Paint()
      ..color = t.primary.withOpacity(0.03)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width + size.height; x += 40) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t.id != t.id;
}

// ── Per-theme card preview painter ───────────────────────────────────────────
class _ThemeCardPainter extends CustomPainter {
  final AppTheme t;
  final bool isSelected;
  _ThemeCardPainter(this.t, this.isSelected);

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.card, t.cardLight, t.background],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Glowing orb right side
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          colors: [
            t.primary.withOpacity(isSelected ? 0.28 : 0.15),
            Colors.transparent
          ],
        ).createShader(Rect.fromCircle(
            center: Offset(size.width * 0.9, size.height * 0.3),
            radius: size.height * 1.1)),
    );

    // Scan lines
    final scan = Paint()
      ..color = t.primary.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 7) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scan);
    }

    // Arc accent
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width + 8, size.height + 8),
          radius: size.height * 1.0),
      3.4, 1.0, false,
      Paint()
        ..color = t.primary.withOpacity(isSelected ? 0.18 : 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ThemeCardPainter old) =>
      old.t.id != t.id || old.isSelected != isSelected;
}