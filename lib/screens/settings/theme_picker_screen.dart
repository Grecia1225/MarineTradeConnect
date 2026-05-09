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
      body: SafeArea(
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
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final theme     = tp.themes[index];
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

                          Positioned.fill(
                            child: Image.network(
                              theme.backgroundImage,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(color: theme.card);
                              },
                              errorBuilder: (_, __, ___) =>
                                  Container(color: theme.card),
                            ),
                          ),

                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  theme.background.withOpacity(
                                      isSelected ? 0.55 : 0.75),
                                  theme.background.withOpacity(0.2),
                                ]),
                              ),
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
                                child: Center(child: Text(theme.emoji,
                                    style: const TextStyle(fontSize: 22))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(theme.name,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    _dot(theme.background),
                                    _dot(theme.primary),
                                    _dot(theme.card),
                                  ]),
                                ],
                              )),
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