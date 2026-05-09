import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/utils/language_provider.dart';
import 'package:mtc/screens/marketplace/marketplace_screen.dart';
import 'package:mtc/screens/marketplace/create_listing_screen.dart';
import 'package:mtc/screens/marketplace/my_listings_screen.dart';
import 'package:mtc/screens/marketplace/secondhand_screen.dart';
import 'package:mtc/screens/chat/chat_list_screen.dart';
import 'package:mtc/screens/trackingg/tracking_screen.dart';
import 'package:mtc/screens/settings/theme_picker_screen.dart';
import 'package:mtc/screens/settings/account_settings_screen.dart';
import 'package:mtc/screens/settings/notifications_screen.dart';
import 'package:mtc/screens/settings/privacy_screen.dart';
import 'package:mtc/screens/settings/help_support_screen.dart';
import 'package:mtc/screens/settings/terms_screen.dart';
import 'package:mtc/screens/settings/about_screen.dart';
import 'package:mtc/screens/settings/language_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int    _tab      = 0;
  String _userName = '';
  String _userRole = '';
  String _email    = '';
  bool   _loaded   = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(user.uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _userName = doc.data()?['name'] ?? user.displayName ?? 'Trader';
        _userRole = doc.data()?['role'] ?? 'buyer';
        _email    = user.email ?? '';
        _loaded   = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;

    // ✅ Don't render IndexedStack until user data is loaded
    if (!_loaded) {
      return Scaffold(
        backgroundColor: t.background,
        body: Center(
          child: CircularProgressIndicator(
              color: t.primary, strokeWidth: 2)),
      );
    }

    final screens = [
      // ✅ Builder gives HomeTab a valid Navigator context
      Builder(builder: (ctx) => _HomeTab(
        userName:    _userName,
        userRole:    _userRole,
        navContext:  ctx,
        onTabChange: (i) => setState(() => _tab = i),
      )),
      const MarketplaceScreen(),
      const ChatListScreen(),
      const TrackingScreen(),
      _ProfileTab(
        userName: _userName,
        userRole: _userRole,
        email:    _email,
      ),
    ];

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: IndexedStack(index: _tab, children: screens),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        t: t,
      ),
    );
  }
}

// ── BOTTOM NAV ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final AppTheme t;
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded,            'Home'),
      (Icons.storefront_rounded,      'Market'),
      (Icons.chat_bubble_rounded,     'Chat'),
      (Icons.directions_boat_rounded, 'Track'),
      (Icons.person_rounded,          'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: t.card,
        border: Border(top: BorderSide(color: t.primary.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final sel = currentIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? t.primary.withOpacity(0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(items[i].$1,
                    color: sel ? t.primary : Colors.white.withOpacity(0.3),
                    size: 21),
                if (sel) ...[
                  const SizedBox(width: 5),
                  Text(items[i].$2,
                      style: TextStyle(color: t.primary,
                          fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// ── HOME TAB ──────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final String userName;
  final String userRole;
  final BuildContext navContext;
  final Function(int) onTabChange;

  const _HomeTab({
    required this.userName,
    required this.userRole,
    required this.navContext,
    required this.onTabChange,
  });

  void _go(Widget w) =>
      Navigator.push(navContext, MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final t         = Provider.of<ThemeProvider>(context).current;
    final uid       = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isSeller  = userRole == 'seller';
    final isShipper = userRole == 'shipper' || userRole == 'agent';
    final isBuyer   = userRole == 'buyer';
    final hour      = DateTime.now().hour;
    final greeting  = hour < 12 ? 'Good morning'
                    : hour < 17 ? 'Good afternoon'
                    : 'Good evening';

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [t.card, t.background],
            ),
          ),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting 👋',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45), fontSize: 13)),
                const SizedBox(height: 3),
                Text(userName.isEmpty ? 'Trader' : userName,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            )),
            GestureDetector(
              onTap: () => onTabChange(4),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: t.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: t.primary.withOpacity(0.5), width: 1.5),
                ),
                child: Center(child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(color: t.primary,
                      fontWeight: FontWeight.w800, fontSize: 17),
                )),
              ),
            ),
          ]),
        ),

        // ── Role badge + Hero ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.primary.withOpacity(0.35)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      isSeller ? Icons.storefront_outlined
                          : isShipper ? Icons.directions_boat_outlined
                          : Icons.shopping_bag_outlined,
                      color: t.primary, size: 12,
                    ),
                    const SizedBox(width: 5),
                    Text(userRole.toUpperCase(),
                        style: TextStyle(color: t.primary,
                            fontSize: 10, fontWeight: FontWeight.w700,
                            letterSpacing: 1.1)),
                  ]),
                ),
              ),

              // Hero banner
              Container(
                width: double.infinity, height: 140,
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: t.primary.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Stack(children: [
                    Positioned(right: -8, top: 0, bottom: 0,
                        child: Icon(Icons.anchor,
                            color: t.primary.withOpacity(0.07), size: 110)),
                    Positioned(left: 0, top: 0, bottom: 0,
                        child: Container(width: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, t.primary,
                                  Colors.transparent],
                              ),
                            ))),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Marine Trade Connect',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(
                                isSeller
                                    ? 'List & sell — anything shipped by sea'
                                    : isShipper
                                        ? 'Accept shipments — grow your fleet'
                                        : 'Buy anything — shipped anywhere',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 11),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => onTabChange(1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: t.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isSeller ? 'Post listing'
                                    : isShipper ? 'View shipments'
                                    : 'Browse market',
                                style: TextStyle(color: t.background,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),

        // ── Stats ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _StatCards(
              uid: uid, role: userRole, t: t,
              onTabChange: onTabChange),
        ),

        // ── Quick actions ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick actions',
                  style: TextStyle(color: Colors.white,
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              Row(children: [
                _action(
                  isSeller ? 'Post listing' : 'Browse',
                  isSeller ? Icons.add_box_rounded
                      : Icons.storefront_rounded,
                  t.primary,
                  isSeller
                      ? () => _go(const CreateListingScreen())
                      : () => onTabChange(1),
                  t,
                ),
                const SizedBox(width: 10),
                _action('Track', Icons.directions_boat_rounded,
                    const Color(0xFFFF6B6B), () => onTabChange(3), t),
              ]),

              const SizedBox(height: 10),

              Row(children: [
                _action('Messages', Icons.chat_bubble_rounded,
                    const Color(0xFFAB87FF), () => onTabChange(2), t),
                const SizedBox(width: 10),
                _action(
                  isSeller ? 'My Listings'
                      : isBuyer ? 'My Orders' : 'Shipments',
                  isSeller ? Icons.inventory_2_rounded
                      : isBuyer ? Icons.receipt_long_rounded
                      : Icons.local_shipping_rounded,
                  const Color(0xFF06D6A0),
                  isSeller
                      ? () => _go(const MyListingsScreen())
                      : () => onTabChange(3),
                  t,
                ),
              ]),

              const SizedBox(height: 10),

              // Secondhand banner
              GestureDetector(
                onTap: () => _go(const SecondhandScreen()),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.recycling,
                          color: Colors.orange, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Secondhand',
                            style: TextStyle(color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        Text('Trade used goods — give items a second life',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 11)),
                      ],
                    )),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withOpacity(0.2), size: 13),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // ── Recent activity ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent activity',
                      style: TextStyle(color: Colors.white,
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => onTabChange(3),
                    child: Text('View all',
                        style: TextStyle(
                            color: t.primary.withOpacity(0.7),
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _RecentActivity(uid: uid, role: userRole, t: t),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _action(String label, IconData icon, Color color,
      VoidCallback onTap, AppTheme t) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
              style: const TextStyle(color: Colors.white,
                  fontSize: 12, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis)),
        ]),
      ),
    ));
  }
}

// ── STAT CARDS ────────────────────────────────────────────────────────────────
class _StatCards extends StatelessWidget {
  final String uid;
  final String role;
  final AppTheme t;
  final Function(int) onTabChange;
  const _StatCards({
    required this.uid, required this.role,
    required this.t,   required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final defs = _getDefs();
    return Row(
      children: List.generate(defs.length, (i) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
          child: StreamBuilder<QuerySnapshot>(
            stream: defs[i].stream,
            builder: (_, snap) {
              final count = snap.data?.docs.length ?? 0;
              return GestureDetector(
                onTap: defs[i].onTap,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(defs[i].icon, color: t.primary, size: 17),
                      const SizedBox(height: 7),
                      Text('$count',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(defs[i].label,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      )),
    );
  }

  List<_Def> _getDefs() {
    final fs = FirebaseFirestore.instance;
    if (role == 'seller') return [
      _Def('Listings', Icons.list_alt_rounded,
          fs.collection('listings')
              .where('sellerId', isEqualTo: uid).snapshots(),
          () => onTabChange(1)),
      _Def('Orders', Icons.receipt_long_rounded,
          fs.collection('shipments')
              .where('sellerId', isEqualTo: uid).snapshots(),
          () => onTabChange(3)),
      _Def('Chats', Icons.chat_bubble_rounded,
          fs.collection('chats')
              .where('participants', arrayContains: uid).snapshots(),
          () => onTabChange(2)),
    ];
    if (role == 'shipper' || role == 'agent') return [
      _Def('Available', Icons.pending_rounded,
          fs.collection('shipments')
              .where('status', isEqualTo: 'pending').snapshots(),
          () => onTabChange(3)),
      _Def('My Ships', Icons.directions_boat_rounded,
          fs.collection('shipments')
              .where('shipperId', isEqualTo: uid).snapshots(),
          () => onTabChange(3)),
      _Def('Chats', Icons.chat_bubble_rounded,
          fs.collection('chats')
              .where('participants', arrayContains: uid).snapshots(),
          () => onTabChange(2)),
    ];
    return [
      _Def('Orders', Icons.shopping_bag_rounded,
          fs.collection('shipments')
              .where('buyerId', isEqualTo: uid).snapshots(),
          () => onTabChange(3)),
      _Def('In Transit', Icons.directions_boat_rounded,
          fs.collection('shipments')
              .where('buyerId', isEqualTo: uid)
              .where('status', isEqualTo: 'in_transit').snapshots(),
          () => onTabChange(3)),
      _Def('Chats', Icons.chat_bubble_rounded,
          fs.collection('chats')
              .where('participants', arrayContains: uid).snapshots(),
          () => onTabChange(2)),
    ];
  }
}

class _Def {
  final String label;
  final IconData icon;
  final Stream<QuerySnapshot> stream;
  final VoidCallback onTap;
  const _Def(this.label, this.icon, this.stream, this.onTap);
}

// ── RECENT ACTIVITY ───────────────────────────────────────────────────────────
class _RecentActivity extends StatelessWidget {
  final String uid;
  final String role;
  final AppTheme t;
  const _RecentActivity(
      {required this.uid, required this.role, required this.t});

  @override
  Widget build(BuildContext context) {
    final stream = role == 'seller'
        ? FirebaseFirestore.instance
            .collection('shipments')
            .where('sellerId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(3)
            .snapshots()
        : FirebaseFirestore.instance
            .collection('shipments')
            .where('buyerId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .limit(3)
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: t.card.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(children: [
              Icon(Icons.anchor,
                  color: t.primary.withOpacity(0.2), size: 32),
              const SizedBox(height: 8),
              Text('No activity yet',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13)),
            ]),
          );
        }
        return Column(
          children: docs.map((doc) {
            final d      = doc.data() as Map<String, dynamic>;
            final status = (d['status'] ?? 'pending') as String;
            final label  = status[0].toUpperCase() +
                status.substring(1).replaceAll('_', ' ');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: t.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.directions_boat_rounded,
                      color: t.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['listingTitle'] ?? 'Order',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    Text(
                      role == 'seller'
                          ? 'Buyer: ${d['buyerName'] ?? ''}'
                          : 'Seller: ${d['sellerName'] ?? ''}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11),
                    ),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: t.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(label,
                      style: TextStyle(color: t.primary,
                          fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ]),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── PROFILE TAB ───────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final String userName;
  final String userRole;
  final String email;
  const _ProfileTab({
    required this.userName,
    required this.userRole,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final t    = Provider.of<ThemeProvider>(context).current;
    final lang = Provider.of<LanguageProvider>(context);

    // ✅ FIXED: uses lang.currentCode (getter now exists in LanguageProvider)
    final currentLang = LanguageProvider.supportedLanguages.firstWhere(
      (l) => l['code'] == lang.currentCode,
      orElse: () => LanguageProvider.supportedLanguages.first,
    );

    return SingleChildScrollView(
      child: Column(children: [

        // Avatar header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [t.card, t.background],
            ),
          ),
          child: Column(children: [
            Container(
              width: 74, height: 74,
              decoration: BoxDecoration(
                color: t.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: t.primary.withOpacity(0.5), width: 2),
              ),
              child: Center(child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(color: t.primary,
                    fontSize: 28, fontWeight: FontWeight.w800),
              )),
            ),
            const SizedBox(height: 12),
            Text(userName.isEmpty ? 'Trader' : userName,
                style: const TextStyle(color: Colors.white,
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(email,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: t.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.primary.withOpacity(0.35)),
              ),
              child: Text(userRole.toUpperCase(),
                  style: TextStyle(color: t.primary,
                      fontSize: 10, fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
            ),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [

            _section('Personalisation', [
              _tile(Icons.palette_rounded, 'App theme',
                  'Choose your colour scheme', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const ThemePickerScreen()))),
              _tile(Icons.language_rounded, 'Language',
                  '${currentLang['flag']} ${currentLang['name']}', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const LanguageScreen()))),
              _tile(Icons.person_rounded, 'Edit profile',
                  'Update your info', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AccountSettingsScreen()))),
              if (userRole == 'seller' || userRole == 'agent')
                _tile(Icons.inventory_2_rounded, 'My Listings',
                    'View & manage your posts', t,
                    () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const MyListingsScreen()))),
            ], t),

            const SizedBox(height: 14),

            _section('Preferences', [
              _tile(Icons.notifications_rounded, 'Notifications',
                  'Manage alerts', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()))),
              _tile(Icons.shield_rounded, 'Privacy & Security',
                  'Control your data', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const PrivacyScreen()))),
            ], t),

            const SizedBox(height: 14),

            _section('Support', [
              _tile(Icons.help_rounded, 'Help & Support',
                  'FAQs and contact', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen()))),
              _tile(Icons.description_rounded, 'Terms & Conditions',
                  'Legal info', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const TermsScreen()))),
              _tile(Icons.info_rounded, 'About MTC', 'Version info', t,
                  () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AboutScreen()))),
            ], t),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () async => await FirebaseAuth.instance.signOut(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.redAccent.withOpacity(0.25)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 17),
                    SizedBox(width: 8),
                    Text('Sign out',
                        style: TextStyle(color: Colors.redAccent,
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }

  Widget _section(String title, List<Widget> items, AppTheme t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(),
            style: TextStyle(color: t.primary.withOpacity(0.6),
                fontSize: 10, fontWeight: FontWeight.w800,
                letterSpacing: 1.5)),
      ),
      Container(
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: List.generate(items.length, (i) => Column(children: [
            items[i],
            if (i < items.length - 1)
              Divider(color: Colors.white.withOpacity(0.05),
                  height: 1, indent: 56),
          ])),
        ),
      ),
    ]);
  }

  Widget _tile(IconData icon, String label, String subtitle,
      AppTheme t, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: t.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: t.primary, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white,
                  fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(
                  color: Colors.white.withOpacity(0.35), fontSize: 11)),
            ],
          )),
          Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.15), size: 12),
        ]),
      ),
    );
  }
}