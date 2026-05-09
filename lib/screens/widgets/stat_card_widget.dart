import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';

/// Live stat card that fetches real counts from Firestore
class LiveStatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String collection;
  final String field; // field to filter by current user uid

  const LiveStatCard({
    super.key,
    required this.label,
    required this.icon,
    required this.collection,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collection)
            .where(field, isEqualTo: uid)
            .snapshots(),
        builder: (context, snap) {
          final count = snap.data?.docs.length ?? 0;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.primary.withOpacity(0.12)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: t.primary, size: 18),
              const SizedBox(height: 8),
              Text(
                snap.connectionState == ConnectionState.waiting ? '—' : '$count',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ]),
          );
        },
      ),
    );
  }
}