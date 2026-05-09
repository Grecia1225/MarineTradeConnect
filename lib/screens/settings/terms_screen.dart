import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background, elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.primary.withOpacity(0.25))),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 15))),
        title: const Text('Terms & Conditions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _header('Last updated: April 2026', t),
          _section('1. Acceptance of Terms', 'By downloading, registering, or using the Marine Trade Connect (MTC) application, you agree to be legally bound by these Terms and Conditions. If you disagree with any part of these terms, you must not use the application. Your continued use of the platform constitutes acceptance of any updates to these terms.', t),
          _section('2. Eligibility & User Accounts', 'You must be at least 18 years of age to register and use MTC. By creating an account, you confirm that all information provided is accurate, current, and complete. You are solely responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. MTC reserves the right to suspend or terminate accounts that provide false information or violate these terms.', t),
          _section('3. User Roles', 'MTC offers three roles — Buyer, Seller, and Agent. Buyers may browse and purchase listed goods. Sellers may post listings and manage orders. Agents may facilitate deals between buyers and sellers. Each role comes with its own responsibilities as outlined in these terms. Role changes require approval from the MTC support team.', t),
          _section('4. Marketplace Listings', 'All listings posted on MTC must be genuine, accurately described, and legally permitted for trade. Sellers must ensure that product details — including price, quantity, category, and condition — are truthful. MTC reserves the right to remove any listing that is misleading, fraudulent, or violates applicable laws without prior notice. Repeated violations will result in permanent account suspension.', t),
          _section('5. Transactions & Payments', 'MTC is a marketplace platform and does not process, hold, or guarantee any payments. All financial transactions occur directly between the buyer and seller. MTC is not a party to any transaction and accepts no liability for payment disputes, non-delivery, product quality issues, or any losses arising from transactions made on the platform. We strongly recommend using traceable payment methods such as UPI, NEFT, or bank transfer.', t),
          _section('6. Shipments & Tracking', 'Shipment tracking features on MTC are provided for informational purposes only. MTC does not operate, own, or guarantee any logistics or delivery services. The accuracy of shipment status updates depends on the seller and shipper updating the platform correctly. MTC is not liable for delays, losses, or damages that occur during transit.', t),
          _section('7. Prohibited Conduct', 'Users must not: (a) post false, misleading, or fraudulent listings; (b) impersonate other users or entities; (c) engage in harassment, abuse, or threatening behaviour towards other users; (d) use the platform to trade in illegal, prohibited, or regulated goods; (e) attempt to reverse-engineer, scrape, or exploit the platform; (f) use automated systems or bots to interact with the platform; (g) attempt to bypass security measures or access unauthorised areas.', t),
          _section('8. Intellectual Property', 'All content, design, branding, logos, and technology on the MTC platform are the exclusive intellectual property of Marine Trade Connect. You may not reproduce, distribute, modify, or create derivative works without prior written permission. User-generated content (listings, messages, photos) remains the property of the respective user, but by posting on MTC, you grant MTC a non-exclusive licence to display and process this content for platform operations.', t),
          _section('9. Privacy', 'Your use of MTC is also governed by our Privacy Policy, which is incorporated into these Terms by reference. By using MTC, you consent to the collection and use of your information as described in the Privacy Policy. Please review the Privacy Policy carefully before using the platform.', t),
          _section('10. Disclaimers & Limitation of Liability', 'MTC is provided on an "as is" and "as available" basis without warranties of any kind, either express or implied. We do not warrant that the platform will be uninterrupted, error-free, or free from viruses. To the fullest extent permitted by law, MTC shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of or inability to use the platform.', t),
          _section('11. Indemnification', 'You agree to indemnify and hold harmless Marine Trade Connect, its officers, directors, employees, and partners from any claims, liabilities, damages, losses, or expenses (including legal fees) arising out of or in connection with your use of the platform, your violation of these Terms, or your violation of any rights of another user.', t),
          _section('12. Changes to Terms', 'MTC reserves the right to update or modify these Terms at any time. We will notify users of significant changes via in-app notifications or email. Your continued use of the platform after such changes constitutes your acceptance of the revised Terms. We encourage you to review these Terms periodically.', t),
          _section('13. Governing Law & Disputes', 'These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising from or related to these Terms or the use of MTC shall be subject to the exclusive jurisdiction of the courts located in Mumbai, Maharashtra, India. We encourage users to resolve disputes amicably through our support team before pursuing legal action.', t),
          _section('14. Contact Information', 'If you have any questions, concerns, or feedback regarding these Terms, please contact our legal team:\n\nEmail: legal@mtc.in\nPhone: +91 80000 00000\nAddress: Marine Trade Connect Pvt Ltd, Mumbai Port Area, Maharashtra - 400001, India', t),
        ],
      ),
    );
  }

  Widget _header(String text, AppTheme t) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Text(text, style: TextStyle(color: t.primary.withOpacity(0.6), fontSize: 12)),
  );

  Widget _section(String title, String body, AppTheme t) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 10),
      Text(body, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13, height: 1.7)),
    ]),
  );
}