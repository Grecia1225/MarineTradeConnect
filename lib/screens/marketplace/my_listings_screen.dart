import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/models/listing.dart';
import 'package:mtc/screens/marketplace/listing_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t   = Provider.of<ThemeProvider>(context).current;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
              const Text('My Listings',
                  style: TextStyle(color: Colors.white,
                      fontSize: 19, fontWeight: FontWeight.w800)),
            ]),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .where('sellerId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(
                      color: t.primary, strokeWidth: 2));
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: t.primary.withOpacity(0.2), size: 48),
                      const SizedBox(height: 12),
                      Text('No listings yet',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14)),
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
                    final listing = Listing.fromDoc(docs[i]);
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              ListingDetailScreen(listing: listing))),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: t.primary.withOpacity(0.1)),
                        ),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: listing.imageUrls.isNotEmpty
                                ? Image.network(
                                    listing.imageUrls.first,
                                    width: 64, height: 64,
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
                              Text(listing.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 3),
                              Text(listing.formattedPrice,
                                  style: TextStyle(color: t.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                              const SizedBox(height: 3),
                              Text(listing.sellerLocation,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 11),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          )),
                          GestureDetector(
                            onTap: () => _del(context, t, docs[i].id),
                            child: Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.2)),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 17),
                            ),
                          ),
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
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: t.cardLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.image_outlined,
            color: t.primary.withOpacity(0.3), size: 26),
      );

  Future<void> _del(
      BuildContext context, AppTheme t, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete listing?',
            style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.w700)),
        content: Text('This cannot be undone.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.5))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseFirestore.instance
          .collection('listings').doc(id).delete();
    }
  }
}