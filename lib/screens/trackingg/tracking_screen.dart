import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Shipments', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              Text('All your orders & deliveries', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12)),
            ]),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('shipments')
                  .where('buyerId', isEqualTo: user?.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, buyerSnap) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('shipments')
                      .where('sellerId', isEqualTo: user?.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, sellerSnap) {
                    final buyerDocs = buyerSnap.data?.docs ?? [];
                    final sellerDocs = sellerSnap.data?.docs ?? [];
                    final seen = <String>{};
                    final docs = [...buyerDocs, ...sellerDocs].where((d) => seen.add(d.id)).toList();

                    if (docs.isEmpty) {
                      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.directions_boat_outlined, color: t.primary.withOpacity(0.2), size: 56),
                        const SizedBox(height: 14),
                        Text('No shipments yet', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Orders you place or receive appear here', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12)),
                      ]));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final isBuyer = data['buyerId'] == user?.uid;
                        final isSeller = data['sellerId'] == user?.uid;
                        return _ShipmentCard(data: data, docId: docs[i].id, isBuyer: isBuyer, isSeller: isSeller, t: t);
                      },
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
}

class _ShipmentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final bool isBuyer;
  final bool isSeller;
  final AppTheme t;

  const _ShipmentCard({required this.data, required this.docId, required this.isBuyer, required this.isSeller, required this.t});

  static const _steps    = ['pending', 'confirmed', 'picked_up', 'in_transit', 'delivered'];
  static const _labels   = ['Pending', 'Confirmed', 'Picked Up', 'In Transit', 'Delivered'];
  static const _icons    = [Icons.hourglass_empty, Icons.check_circle_outline, Icons.inventory_2_outlined, Icons.directions_boat_outlined, Icons.where_to_vote_outlined];

  Future<void> _updateStatus(String next) async {
    await FirebaseFirestore.instance.collection('shipments').doc(docId).update({
      'status': next,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final stepIndex = _steps.indexOf(status).clamp(0, _steps.length - 1);
    final isDelivered = status == 'delivered';
    final totalPrice = data['totalPrice'] ?? 0;
    final qty = data['quantityKg'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDelivered ? Colors.green.withOpacity(0.3) : t.primary.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['listingTitle'] ?? 'Order', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              isBuyer ? 'Seller: ${data['sellerName'] ?? ''}' : 'Buyer: ${data['buyerName'] ?? 'Buyer'}',
              style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
            ),
            if (qty > 0 || totalPrice > 0) ...[
              const SizedBox(height: 3),
              Text('${qty.toString()} kg • ₹${totalPrice.toString()}', style: TextStyle(color: t.primary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDelivered ? Colors.green.withOpacity(0.12) : t.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_labels[stepIndex], style: TextStyle(color: isDelivered ? Colors.green : t.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),

        const SizedBox(height: 20),

        // Progress stepper
        Row(children: List.generate(_steps.length, (i) {
          final done = i <= stepIndex;
          final active = i == stepIndex;
          return Expanded(child: Row(children: [
            Column(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? (isDelivered ? Colors.green : t.primary) : t.background,
                  border: Border.all(color: done ? (isDelivered ? Colors.green : t.primary) : Colors.white.withOpacity(0.15), width: 1.5),
                ),
                child: Icon(_icons[i], size: 13, color: done ? Colors.black : Colors.white.withOpacity(0.25)),
              ),
              const SizedBox(height: 4),
              Text(_labels[i], style: TextStyle(color: done ? Colors.white : Colors.white.withOpacity(0.25), fontSize: 8, fontWeight: active ? FontWeight.w700 : FontWeight.normal), textAlign: TextAlign.center),
            ]),
            if (i < _steps.length - 1)
              Expanded(child: Container(height: 1.5, color: i < stepIndex ? (isDelivered ? Colors.green : t.primary) : Colors.white.withOpacity(0.1))),
          ]));
        })),

        // Seller actions to advance status
        if (isSeller && !isDelivered) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateStatus(_steps[stepIndex + 1]),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary.withOpacity(0.15), foregroundColor: t.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: Text('Mark as ${_labels[stepIndex + 1]}', style: const TextStyle(fontWeight: FontWeight.w700)),
            )),
        ],

        // Role label
        const SizedBox(height: 10),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isBuyer ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(isBuyer ? 'YOUR ORDER' : 'YOUR SALE', style: TextStyle(color: isBuyer ? Colors.blue : Colors.green, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ]),
      ]),
    );
  }
}