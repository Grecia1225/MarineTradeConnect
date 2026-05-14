import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  static const _gold = Color(0xFFF4A532);
  static const _navy = Color(0xFF060F1E);

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'buyer',
      'title': 'Buyer',
      'subtitle': 'Browse and purchase marine products',
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFF4488FF),
      'perks': ['Browse all listings', 'Contact sellers directly', 'Track your orders'],
    },
    {
      'id': 'seller',
      'title': 'Seller',
      'subtitle': 'List and sell your marine products',
      'icon': Icons.storefront_outlined,
      'color': Color(0xFF00C896),
      'perks': ['Post unlimited listings', 'Manage orders', 'Chat with buyers'],
    },
    {
      'id': 'agent',
      'title': 'Agent',
      'subtitle': 'Facilitate marine trade deals & logistics',
      'icon': Icons.handshake_outlined,
      'color': Color(0xFFF4A532),
      'perks': ['Access all listings', 'Mediate transactions', 'Build your network'],
    },
  ];

  Future<void> _confirm() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a role to continue.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'role': _selectedRole}, SetOptions(merge: true));

      // ✅ Save to SharedPreferences so main.dart routes instantly next time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role_${user.uid}', _selectedRole!);
      await prefs.setBool('profile_complete_${user.uid}', false);

      if (mounted) Navigator.pushReplacementNamed(context, '/profile-setup');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Zero-data background
          SizedBox.expand(child: Image.asset(
            'assets/images/role_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                CustomPaint(painter: _AuthBgPainter(_navy, _gold)),
          )),
          Container(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [_navy.withOpacity(0.8), _navy.withOpacity(0.95), _navy],
          ))),

          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(height: 3, decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, _gold, Colors.transparent]),
            )),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: List.generate(3, (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i == 0 ? _gold : Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ))),
                    const SizedBox(height: 28),
                    const Text("What's your role?",
                        style: TextStyle(color: Colors.white, fontSize: 26,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('This helps us tailor your experience',
                        style: TextStyle(color: _gold.withOpacity(0.6), fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    itemCount: _roles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final role     = _roles[i];
                      final selected = _selectedRole == role['id'];
                      final color    = role['color'] as Color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRole = role['id']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withOpacity(0.12)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected ? color : Colors.white.withOpacity(0.1),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: color.withOpacity(selected ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(role['icon'] as IconData,
                                  color: color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(role['title'] as String,
                                      style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.85),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 3),
                                  Text(role['subtitle'] as String,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 12)),
                                  const SizedBox(height: 12),
                                  ...(role['perks'] as List<String>).map((p) =>
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(children: [
                                          Icon(Icons.check_circle_outline,
                                              color: color, size: 13),
                                          const SizedBox(width: 6),
                                          Text(p,
                                              style: TextStyle(
                                                  color: Colors.white.withOpacity(0.55),
                                                  fontSize: 12)),
                                        ]),
                                      )),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected ? color : Colors.transparent,
                                border: Border.all(
                                    color: selected ? color : Colors.white24,
                                    width: 1.5),
                              ),
                              child: selected
                                  ? const Icon(Icons.check,
                                      size: 13, color: Colors.white)
                                  : null,
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
                  child: SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: _navy,
                        disabledBackgroundColor: _gold.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Continue',
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF060F1E))),
                    ),
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

// ── Shared auth background painter ───────────────────────────────────────────
class _AuthBgPainter extends CustomPainter {
  final Color navy;
  final Color gold;
  _AuthBgPainter(this.navy, this.gold);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = navy);

    // Top-right glow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          colors: [gold.withOpacity(0.12), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(size.width, 0), radius: size.height * 0.7)),
    );

    // Bottom-left glow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          colors: [gold.withOpacity(0.06), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(0, size.height), radius: size.height * 0.6)),
    );

    // Diagonal lines
    final line = Paint()
      ..color = gold.withOpacity(0.03)
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width + size.height; x += 40) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), line);
    }

    // Anchor watermark
    final textPainter = TextPainter(
      text: TextSpan(
        text: '⚓',
        style: TextStyle(
            fontSize: size.width * 0.55,
            color: gold.withOpacity(0.03)),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.5 - textPainter.width / 2,
          size.height * 0.3 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_AuthBgPainter old) => false;
}