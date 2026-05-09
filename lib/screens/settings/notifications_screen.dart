import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _newListings = true;
  bool _messages = true;
  bool _priceAlerts = false;
  bool _shipmentUpdates = true;
  bool _promotions = false;
  bool _appSounds = true;

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.primary.withOpacity(0.25)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white70, size: 15),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [

          _sectionHeader('Activity', t),
          _toggle('New listings nearby', 'Get notified about new marine listings',
              Icons.storefront_outlined, _newListings, t, (v) {
            setState(() => _newListings = v);
          }),
          _toggle('Messages', 'New messages from traders',
              Icons.chat_bubble_outline, _messages, t, (v) {
            setState(() => _messages = v);
          }),
          _toggle('Shipment updates', 'Track your shipments in real-time',
              Icons.directions_boat_outlined, _shipmentUpdates, t, (v) {
            setState(() => _shipmentUpdates = v);
          }),

          const SizedBox(height: 8),
          _sectionHeader('Market', t),
          _toggle('Price alerts', 'Get alerts when prices drop or spike',
              Icons.show_chart, _priceAlerts, t, (v) {
            setState(() => _priceAlerts = v);
          }),
          _toggle('Promotions', 'Deals and offers from sellers',
              Icons.local_offer_outlined, _promotions, t, (v) {
            setState(() => _promotions = v);
          }),

          const SizedBox(height: 8),
          _sectionHeader('Preferences', t),
          _toggle('App sounds', 'Play sounds for notifications',
              Icons.volume_up_outlined, _appSounds, t, (v) {
            setState(() => _appSounds = v);
          }),

          const SizedBox(height: 32),

          // Info note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: t.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Push notifications require device permissions to be enabled.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
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

  Widget _sectionHeader(String title, AppTheme t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: t.primary.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _toggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    AppTheme t,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: t.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: t.primary,
            activeTrackColor: t.primary.withOpacity(0.25),
            inactiveThumbColor: Colors.white30,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}