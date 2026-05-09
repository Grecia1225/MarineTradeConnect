import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/models/listing.dart';
import 'package:mtc/screens/marketplace/listing_detail_screen.dart';

class SecondhandScreen extends StatefulWidget {
  const SecondhandScreen({super.key});
  @override
  State<SecondhandScreen> createState() => _SecondhandScreenState();
}

class _SecondhandScreenState extends State<SecondhandScreen> {
  String _search = '';
  String _role   = '';
  final _searchCtrl = TextEditingController();

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
    if (mounted) setState(() => _role = doc.data()?['role'] ?? 'buyer');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _postItem(AppTheme t) async {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    final imgCtrl   = TextEditingController();
    String category = 'Equipment';

    final cats = [
      'Equipment', 'Boats & Vessels', 'Fishing Gear',
      'Navigation Tools', 'Engine Parts', 'Safety Equipment',
      'Cargo Containers', 'Marine Electronics', 'Ropes & Anchors',
      'Other',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24,
              MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('List secondhand item',
                        style: TextStyle(color: Colors.white,
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close,
                          color: Colors.white54, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sheetField('Item name *', titleCtrl, t),
                const SizedBox(height: 12),
                _sheetField('Price (₹) *', priceCtrl, t,
                    type: TextInputType.number),
                const SizedBox(height: 12),
                Text('Category',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: t.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      dropdownColor: t.card,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      items: cats.map((c) => DropdownMenuItem(
                          value: c, child: Text(c))).toList(),
                      onChanged: (v) =>
                          setModalState(() => category = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _sheetField('Image URL (optional)', imgCtrl, t),
                const SizedBox(height: 12),
                _sheetField('Description / Condition', descCtrl, t,
                    maxLines: 3),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty ||
                          priceCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Name and price required'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ));
                        return;
                      }
                      final user =
                          FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      final userDoc = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(user.uid)
                          .get();
                      final ud = userDoc.data() ?? {};
                      await FirebaseFirestore.instance
                          .collection('secondhand')
                          .add({
                        'sellerId':     user.uid,
                        'sellerName':   ud['name'] ?? '',
                        'sellerLocation': ud['location'] ?? '',
                        'title':        titleCtrl.text.trim(),
                        'description':  descCtrl.text.trim(),
                        'price':        double.tryParse(
                                priceCtrl.text) ?? 0,
                        'category':     category,
                        'imageUrls':    imgCtrl.text.trim().isNotEmpty
                            ? [imgCtrl.text.trim()] : [],
                        'condition':    'used',
                        'status':       'available',
                        'createdAt':    FieldValue.serverTimestamp(),
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Item listed!'),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      foregroundColor: t.background,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('List item',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(String hint, TextEditingController ctrl,
      AppTheme t,
      {TextInputType type = TextInputType.text, int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.25)),
          filled: true,
          fillColor: t.background,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: t.primary.withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white70, size: 15),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Secondhand',
                        style: TextStyle(color: Colors.white,
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('Buy & sell used marine items',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                  ],
                )),
                GestureDetector(
                  onTap: () => _postItem(t),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: t.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: t.primary.withOpacity(0.4)),
                    ),
                    child: Icon(Icons.add, color: t.primary, size: 22),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 14),

            // Info banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: t.primary.withOpacity(0.2)),
                ),
                child: Row(children: [
                  Icon(Icons.recycling, color: t.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Instead of throwing away — sell used marine equipment, parts, gear and more.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12, height: 1.4),
                  )),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // Search
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
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) =>
                      setState(() => _search = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search secondhand items...',
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.25)),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.3),
                        size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Items list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('secondhand')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (_, snap) {
                  if (snap.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(
                        color: t.primary, strokeWidth: 2));
                  }

                  var docs = snap.data?.docs ?? [];
                  if (_search.isNotEmpty) {
                    docs = docs.where((d) {
                      final data =
                          d.data() as Map<String, dynamic>;
                      return (data['title'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(_search);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.recycling,
                            color: t.primary.withOpacity(0.2),
                            size: 48),
                        const SizedBox(height: 12),
                        const Text('No secondhand items yet',
                            style: TextStyle(color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Tap + to list something',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 12)),
                      ],
                    ));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final d = docs[i].data()
                          as Map<String, dynamic>;
                      final imgs = List<String>.from(
                          d['imageUrls'] ?? []);
                      final uid = FirebaseAuth
                          .instance.currentUser?.uid ?? '';
                      final isOwner = d['sellerId'] == uid;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: t.primary.withOpacity(0.1)),
                        ),
                        child: Row(children: [

                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imgs.isNotEmpty
                                ? Image.network(
                                    imgs.first,
                                    width: 70, height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _ph(t))
                                : _ph(t),
                          ),

                          const SizedBox(width: 12),

                          Expanded(child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(child: Text(
                                  d['title'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                )),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: const Text('USED',
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight.w800)),
                                ),
                              ]),
                              const SizedBox(height: 3),
                              Text('₹${d['price']?.toStringAsFixed(0) ?? '0'}',
                                  style: TextStyle(
                                      color: t.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 3),
                              Text(d['category'] ?? '',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 11)),
                              if ((d['description'] ?? '').isNotEmpty)
                                Text(d['description'],
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.35),
                                        fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          )),

                          const SizedBox(width: 8),

                          Column(children: [
                            if (!isOwner)
                              GestureDetector(
                                onTap: () async {
                                  final user = FirebaseAuth
                                      .instance.currentUser;
                                  if (user == null) return;
                                  final chatId = ([user.uid,
                                        d['sellerId'] as String]
                                      ..sort()).join('_');
                                  await FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(chatId)
                                      .set({
                                    'participants':  [user.uid, d['sellerId']],
                                    'listingTitle':  d['title'],
                                    'lastMessage':   '',
                                    'lastUpdated':   FieldValue.serverTimestamp(),
                                    'buyerId':       user.uid,
                                    'sellerId':      d['sellerId'],
                                  }, SetOptions(merge: true));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Chat started! Go to Messages.'),
                                      backgroundColor: Colors.green,
                                      behavior:
                                          SnackBarBehavior.floating,
                                      duration:
                                          Duration(seconds: 2),
                                    ));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: t.primary.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    border: Border.all(
                                        color: t.primary
                                            .withOpacity(0.3)),
                                  ),
                                  child: Icon(Icons.chat_bubble_outline,
                                      color: t.primary, size: 18),
                                ),
                              ),
                            if (isOwner) ...[
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('secondhand')
                                      .doc(docs[i].id)
                                      .delete();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent
                                        .withOpacity(0.08),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 18),
                                ),
                              ),
                            ],
                          ]),
                        ]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph(AppTheme t) => Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: t.cardLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.image_outlined,
            color: t.primary.withOpacity(0.3), size: 24),
      );
}