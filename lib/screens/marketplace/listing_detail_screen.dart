import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/utils/cart_provider.dart';
import 'package:mtc/models/listing.dart';
import 'package:mtc/screens/chat/chat_screen.dart';
import 'package:mtc/screens/marketplace/cart_screen.dart';
import 'package:mtc/utils/voice_provider.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;
    final cart = Provider.of<CartProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == listing.sellerId;
    final inCart = cart.items.any((i) => i.listing.id == listing.id);

    return Scaffold(
      backgroundColor: t.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: t.background,
            leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 15))),
            actions: [
              if (!isOwner)
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(Icons.shopping_cart_outlined,
                          color: t.primary, size: 18),
                      if (cart.count > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                                color: t.primary, shape: BoxShape.circle),
                            child: Center(
                                child: Text('${cart.count}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800)))),
                      ],
                    ]),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: listing.imageUrls.isNotEmpty
                  ? Image.network(listing.imageUrls.first, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: t.card,
                          child: Icon(Icons.image_outlined,
                              color: t.primary.withOpacity(0.3), size: 60)))
                  : Container(
                      color: t.card,
                      child: Icon(Icons.storefront_outlined,
                          color: t.primary.withOpacity(0.3), size: 60)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: t.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: t.primary.withOpacity(0.3))),
                      child: Text(listing.category,
                          style: TextStyle(
                              color: t.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700))),
                  const SizedBox(width: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('Available',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 12),
                Text(listing.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(children: [
                  Text(listing.formattedPrice,
                      style: TextStyle(
                          color: t.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(width: 16),
                  Text('• ${listing.formattedQuantity} available',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 13)),
                ]),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.primary.withOpacity(0.15))),
                  child: Row(children: [
                    Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.primary.withOpacity(0.15),
                            border: Border.all(
                                color: t.primary.withOpacity(0.4), width: 1.5)),
                        child: Center(
                            child: Text(
                                listing.sellerName.isNotEmpty
                                    ? listing.sellerName[0].toUpperCase()
                                    : 'S',
                                style: TextStyle(
                                    color: t.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18)))),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(listing.sellerName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.white.withOpacity(0.35), size: 12),
                            const SizedBox(width: 4),
                            Text(listing.sellerLocation,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.35),
                                    fontSize: 12)),
                          ]),
                        ])),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: t.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: t.primary.withOpacity(0.3))),
                        child: Text('SELLER',
                            style: TextStyle(
                                color: t.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1))),
                  ]),
                ),
                if (listing.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Description',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(listing.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          height: 1.6)),
                ],
                const SizedBox(height: 20),
                const Text('Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _chip(Icons.scale_outlined, 'Quantity',
                        listing.formattedQuantity, t),
                    _chip(Icons.currency_rupee, 'Currency', listing.currency, t),
                    _chip(Icons.category_outlined, 'Category', listing.category,
                        t),
                    _chip(Icons.access_time_outlined, 'Posted',
                        _timeAgo(listing.createdAt), t),
                  ],
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
            color: t.background,
            border: Border(top: BorderSide(color: t.primary.withOpacity(0.1)))),
        child: isOwner
            ? ElevatedButton.icon(
                onPressed: () => _deleteListing(context, t),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete listing',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                    foregroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0))
            : Row(children: [
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                          if (inCart) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CartScreen()));
                          } else {
                            cart.add(listing);

                            // Fix: Hide current snackbar and set duration
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${listing.title} added to cart!'),
                              backgroundColor: Colors.green.shade700,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Cart',
                                textColor: Colors.white,
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const CartScreen())),
                              ),
                            ));
                          }
                        },
                        icon: Icon(inCart ? Icons.shopping_cart : Icons.add_shopping_cart, size: 18),
                        label: Text(inCart ? 'View Cart' : 'Add to Cart',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: t.primary,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0))),
                const SizedBox(width: 12),
                GestureDetector(
                    onTap: () => _openChat(context),
                    child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                            color: t.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: t.primary.withOpacity(0.25))),
                        child: Icon(Icons.chat_bubble_outline,
                            color: t.primary, size: 22))),
              ]),
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value, AppTheme t) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Row(children: [
          Icon(icon, color: t.primary, size: 14),
          const SizedBox(width: 8),
          Expanded( // Added Expanded to prevent overflow
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35), fontSize: 9),
                      overflow: TextOverflow.ellipsis),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ]),
          ),
        ]),
      );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  Future<void> _openChat(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final chatId = ([currentUser.uid, listing.sellerId]..sort()).join('_');
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [currentUser.uid, listing.sellerId],
      'listingId': listing.id,
      'listingTitle': listing.title,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'buyerId': currentUser.uid,
      'sellerId': listing.sellerId,
      'sellerName': listing.sellerName,
      'buyerName': currentUser.displayName ?? 'Buyer',
    }, SetOptions(merge: true));
    if (context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChatScreen(
                    chatId: chatId,
                    otherName: listing.sellerName,
                    otherId: listing.sellerId,
                    listingTitle: listing.title,
                  )));
    }
  }

  Future<void> _deleteListing(BuildContext context, AppTheme t) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: t.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Delete listing?',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              content: Text('This cannot be undone.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel',
                        style:
                            TextStyle(color: Colors.white.withOpacity(0.4)))),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text('Delete')),
              ],
            ));
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listing.id)
          .delete();
      if (context.mounted) Navigator.pop(context);
    }
  }
}