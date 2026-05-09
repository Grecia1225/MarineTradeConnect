import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});
  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final _formKey = GlobalKey<FormState>();

  // Common
  final _phoneCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _bioCtrl      = TextEditingController();

  // Buyer only
  final _whatBuyCtrl  = TextEditingController();
  final _budgetCtrl   = TextEditingController();
  final _portCtrl     = TextEditingController(); // preferred buying port

  // Seller only
  final _companyCtrl  = TextEditingController();
  final _productsCtrl = TextEditingController();
  final _licenseCtrl  = TextEditingController();

  // Shipper / Agent only
  final _vesselCtrl   = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _routesCtrl   = TextEditingController();
  final _imoCtrl      = TextEditingController();

  bool   _isLoading  = true;
  String _role       = '';

  static const _gold = Color(0xFFF4A532);
  static const _navy = Color(0xFF060F1E);

  bool get _isBuyer   => _role == 'buyer';
  bool get _isSeller  => _role == 'seller';
  bool get _isShipper => _role == 'agent' || _role == 'shipper';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _isLoading = false); return; }
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid).get();
    if (mounted) {
      setState(() {
        _role      = (doc.data()?['role'] ?? '').toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _phoneCtrl, _locationCtrl, _bioCtrl,
      _whatBuyCtrl, _budgetCtrl, _portCtrl,
      _companyCtrl, _productsCtrl, _licenseCtrl,
      _vesselCtrl, _capacityCtrl, _routesCtrl, _imoCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final data = <String, dynamic>{
        'phone':           _phoneCtrl.text.trim(),
        'location':        _locationCtrl.text.trim(),
        'bio':             _bioCtrl.text.trim(),
        'profileComplete': true,
      };

      if (_isBuyer) {
        data['whatTheyBuy']     = _whatBuyCtrl.text.trim();
        data['monthlyBudget']   = _budgetCtrl.text.trim();
        data['preferredPort']   = _portCtrl.text.trim();
      } else if (_isSeller) {
        data['company']         = _companyCtrl.text.trim();
        data['productsOffered'] = _productsCtrl.text.trim();
        data['exportLicense']   = _licenseCtrl.text.trim();
      } else {
        data['vesselName']      = _vesselCtrl.text.trim();
        data['cargoCapacity']   = _capacityCtrl.text.trim();
        data['routesServed']    = _routesCtrl.text.trim();
        data['imoNumber']       = _imoCtrl.text.trim();
      }

      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .set(data, SetOptions(merge: true));

      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _role.isEmpty) {
      return const Scaffold(
        backgroundColor: _navy,
        body: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }

    return Scaffold(
      body: Stack(children: [
        SizedBox.expand(child: Image.network(
          'https://images.unsplash.com/photo-1520870028842-5f06cb876136?w=800',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: _navy),
        )),
        Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [_navy.withOpacity(0.82), _navy.withOpacity(0.96), _navy],
        ))),
        Positioned(top: 0, left: 0, right: 0,
          child: Container(height: 3, decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, _gold, Colors.transparent]),
          ))),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Step indicator
                  Row(children: List.generate(3, (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= 1 ? _gold : Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ))),

                  const SizedBox(height: 28),

                  Text(_headline, style: const TextStyle(
                      color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(_subline, style: TextStyle(
                      color: _gold.withOpacity(0.65), fontSize: 13)),

                  // Role badge
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withOpacity(0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_roleIcon, color: _gold, size: 13),
                      const SizedBox(width: 6),
                      Text(_role.toUpperCase(), style: const TextStyle(
                          color: _gold, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    ]),
                  ),

                  const SizedBox(height: 28),

                  // ── COMMON: Phone ──────────────────────────────
                  _label('Phone number'),
                  const SizedBox(height: 8),
                  _textField(_phoneCtrl,
                    hint: '+1 234 567 8901',
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone required';
                      final d = v.replaceAll(RegExp(r'\D'), '');
                      if (d.length < 7) return 'Enter a valid phone number';
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // ── BUYER fields ───────────────────────────────
                  if (_isBuyer) ...[
                    _label('What do you import / buy?'),
                    const SizedBox(height: 8),
                    _textField(_whatBuyCtrl,
                      hint: 'e.g. Electronics, Textiles, Auto parts, Food...',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please tell us what you buy' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Preferred buying port / city'),
                    const SizedBox(height: 8),
                    _textField(_portCtrl,
                      hint: 'e.g. Port of Los Angeles, Hamburg...',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Port required' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Monthly import budget (optional)'),
                    const SizedBox(height: 8),
                    _textField(_budgetCtrl,
                      hint: 'e.g. \$50,000 or leave blank',
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── SELLER fields ──────────────────────────────
                  if (_isSeller) ...[
                    _label('Company / Business name'),
                    const SizedBox(height: 8),
                    _textField(_companyCtrl,
                      hint: 'e.g. Global Marine Exports Ltd',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Company name required' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Products / goods you export'),
                    const SizedBox(height: 8),
                    _textField(_productsCtrl,
                      hint: 'e.g. Machinery, Chemicals, Garments, Steel...',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'List your products' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Export / Trade license number (optional)'),
                    const SizedBox(height: 8),
                    _textField(_licenseCtrl,
                      hint: 'e.g. EXP-2024-12345',
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── SHIPPER / AGENT fields ─────────────────────
                  if (_isShipper) ...[
                    _label('Vessel / Company name'),
                    const SizedBox(height: 8),
                    _textField(_vesselCtrl,
                      hint: 'e.g. Pacific Star Carriers',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Cargo capacity'),
                    const SizedBox(height: 8),
                    _textField(_capacityCtrl,
                      hint: 'e.g. 50,000 DWT or 2,500 TEU',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Capacity required' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Routes / Ports served'),
                    const SizedBox(height: 8),
                    _textField(_routesCtrl,
                      hint: 'e.g. Shanghai → Rotterdam → New York',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'At least one route required' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('IMO number (optional)'),
                    const SizedBox(height: 8),
                    _textField(_imoCtrl,
                      hint: 'e.g. IMO 1234567',
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── COMMON: Location ───────────────────────────
                  _label(_isBuyer
                      ? 'Your country / region'
                      : _isSeller
                          ? 'Origin port / country'
                          : 'Home port / base location'),
                  const SizedBox(height: 8),
                  _textField(_locationCtrl,
                    hint: _isBuyer
                        ? 'e.g. United States, Europe...'
                        : _isSeller
                            ? 'e.g. Port of Shanghai, China'
                            : 'e.g. Port of Singapore',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Location required' : null,
                  ),

                  const SizedBox(height: 18),

                  // ── COMMON: Bio ────────────────────────────────
                  _label('Short bio (optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioCtrl,
                    maxLines: 3,
                    maxLength: 200,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inp(_biohint).copyWith(
                      counterStyle: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 11),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
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
                          : const Text('Complete setup',
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF060F1E))),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/dashboard'),
                      child: Text('Skip for now',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  String get _headline {
    if (_isBuyer)   return 'What do you import?';
    if (_isSeller)  return 'Your business details';
    return 'Your shipping profile';
  }

  String get _subline {
    if (_isBuyer)   return 'Help sellers find the right goods for you';
    if (_isSeller)  return 'Let buyers know what you export';
    return 'Tell us about your vessel and routes';
  }

  String get _biohint {
    if (_isBuyer)   return 'e.g. Wholesale buyer of electronics, 10 years in import...';
    if (_isSeller)  return 'e.g. 15+ years exporting machinery to 30+ countries...';
    return 'e.g. Operating trans-Pacific routes for 8 years...';
  }

  IconData get _roleIcon {
    if (_isBuyer)   return Icons.shopping_bag_outlined;
    if (_isSeller)  return Icons.storefront_outlined;
    return Icons.directions_boat_outlined;
  }

  Widget _label(String t) => Text(t,
      style: TextStyle(color: Colors.white.withOpacity(0.65),
          fontSize: 13, fontWeight: FontWeight.w500));

  Widget _textField(
    TextEditingController ctrl, {
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: _inp(hint),
        validator: validator,
      );

  InputDecoration _inp(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
    filled: true,
    fillColor: Colors.white.withOpacity(0.06),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _gold, width: 1.5)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    errorStyle: const TextStyle(color: Colors.redAccent),
  );
}