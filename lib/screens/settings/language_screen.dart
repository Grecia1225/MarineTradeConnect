import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/utils/language_provider.dart';
import 'package:mtc/utils/app_localizations.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t  = Provider.of<ThemeProvider>(context).current;
    final lp = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: t.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Zero-data background art
          CustomPaint(painter: _BgPainter(t)),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: t.primary.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white70, size: 15),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).t('language'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        Text('Changes apply instantly',
                            style: TextStyle(
                                color: t.primary.withOpacity(0.6),
                                fontSize: 12)),
                      ],
                    ),
                  ]),
                ),

                const SizedBox(height: 24),

                // ── Language list ────────────────────────────────
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: LanguageProvider.supportedLanguages.map((lang) {
                      final selected =
                          lp.locale.languageCode == lang['code'];
                      return GestureDetector(
                        onTap: () {
                          if (!selected) {
                            lp.setLanguage(lang['code']!);
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(
                                  '${lang['flag']} ${lang['name']} selected'),
                              backgroundColor: t.primary.withOpacity(0.9),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ));
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selected
                                ? t.primary.withOpacity(0.12)
                                : t.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? t.primary
                                  : Colors.white.withOpacity(0.06),
                              width: selected ? 1.5 : 1,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                        color: t.primary.withOpacity(0.12),
                                        blurRadius: 12)
                                  ]
                                : [],
                          ),
                          child: Row(children: [
                            // Flag in a themed circle
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: selected
                                    ? t.primary.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(lang['flag']!,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lang['name']!,
                                      style: TextStyle(
                                          color: selected
                                              ? t.primary
                                              : Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text(lang['native']!,
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.4),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? t.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? t.primary
                                      : Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? const Icon(Icons.check_rounded,
                                      size: 14, color: Colors.black)
                                  : null,
                            ),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background painter (matches dashboard style) ──────────────────────────────
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

    final line = Paint()
      ..color = t.primary.withOpacity(0.03)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width + size.height; x += 40) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), line);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t.id != t.id;
}