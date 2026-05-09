import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/models/listing.dart';
import 'package:mtc/screens/marketplace/listing_detail_screen.dart';
import 'package:mtc/screens/marketplace/create_listing_screen.dart';
import 'package:mtc/screens/marketplace/secondhand_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _search   = '';
  String _category = 'All';
  String _role     = '';
  final _searchCtrl = TextEditingController();

  static const _cats = [
    'All',
    'Fresh Fish & Seafood',
    'Frozen Seafood',
    'Grains & Cereals',
    'Crude Oil & Petroleum',
    'Coal & Minerals',
    'Iron & Steel',
    'Chemicals',
    'Industrial Machinery',
    'Vehicles & Automobiles',
    'Marine Equipment',
    'Fishing Gear',
    'Boats & Vessels',
    'Electronics',
    'Textiles & Garments',
    'Containers',
    'Bulk Cargo',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(user.uid).get();
    if (mounted) {
      setState(() => _role = doc.data()?['role'] ?? 'buyer');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(children: [

          // ── Header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Marketplace',
                      style: TextStyle(color: Colors.white,
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  Text('Anything shipped by sea',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12)),
                ],
              )),

              // Secondhand button
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SecondhandScreen())),
                child: Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.35)),
                  ),
                  child: const Icon(Icons.recycling,
                      color: Colors.orange, size: 19),
                ),
              ),

              // Post listing button (seller/shipper only)
              if (_role == 'seller' || _role == 'shipper')
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const CreateListingScreen()))
                      .then((_) => setState(() {})),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: t.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: t.primary.withOpacity(0.4)),
                    ),
                    child: Icon(Icons.add,
                        color: t.primary, size: 22),
                  ),
                ),
            ]),
          ),

          const SizedBox(height: 12),

          // ── Search ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.07)),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14),
                onChanged: (v) =>
                    setState(() => _search = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search listings...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withOpacity(0.3),
                      size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close,
                              color: Colors.white38, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          })
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Category chips ────────────────────────────
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _cats.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 7),
              itemBuilder: (_, i) {
                final cat = _cats[i];
                final sel = _category == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? t.primary : t.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel
                            ? t.primary
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                          color: sel
                              ? t.background
                              : Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w400,
                        )),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── Listings ──────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (_, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: t.primary, strokeWidth: 2));
                }

                var docs = snap.data?.docs ?? [];
                docs = docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final title = (d['title'] ?? '')
                      .toString()
                      .toLowerCase();
                  final cat = (d['category'] ?? '').toString();
                  return (_search.isEmpty ||
                          title.contains(_search)) &&
                      (_category == 'All' ||
                          cat == _category);
                }).toList();

                if (docs.isEmpty) {
                  return Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_outlined,
                          color: t.primary.withOpacity(0.2),
                          size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _search.isNotEmpty
                            ? 'No results for "$_search"'
                            : 'No listings yet',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14),
                      ),
                      if (_role == 'seller' || _role == 'shipper') ...[
                        const SizedBox(height: 8),
                        Text('Tap + to post a listing',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.25),
                                fontSize: 12)),
                      ],
                    ],
                  ));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      20, 0, 20, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final listing = Listing.fromDoc(docs[i]);
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ListingDetailScreen(
                                      listing: listing))),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: t.primary.withOpacity(0.1)),
                        ),
                        child: Row(children: [

                          // Image
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10),
                            child: listing.imageUrls.isNotEmpty
                                ? Image.network(
                                    listing.imageUrls.first,
                                    width: 72, height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _ph(t))
                                : _ph(t),
                          ),

                          const SizedBox(width: 12),

                          // Info
                          Expanded(child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2),
                                  decoration: BoxDecoration(
                                    color: t.primary.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                  ),
                                  child: Text(listing.category,
                                      style: TextStyle(
                                          color: t.primary,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.w700),
                                      overflow:
                                          TextOverflow.ellipsis),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text(listing.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(listing.formattedPrice,
                                  style: TextStyle(
                                      color: t.primary,
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w800)),
                              const SizedBox(height: 3),
                              Row(children: [
                                Icon(Icons.location_on_outlined,
                                    size: 11,
                                    color: Colors.white
                                        .withOpacity(0.3)),
                                const SizedBox(width: 3),
                                Expanded(child: Text(
                                  listing.sellerLocation,
                                  style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.3),
                                      fontSize: 11),
                                  overflow:
                                      TextOverflow.ellipsis,
                                )),
                                Text(listing.formattedQuantity,
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.35),
                                        fontSize: 11)),
                              ]),
                            ],
                          )),

                          const SizedBox(width: 8),

                          Icon(Icons.chevron_right,
                              color: Colors.white.withOpacity(0.2),
                              size: 18),
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _ph(AppTheme t) => Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: t.cardLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.image_outlined,
            color: t.primary.withOpacity(0.2), size: 28),
      );
}