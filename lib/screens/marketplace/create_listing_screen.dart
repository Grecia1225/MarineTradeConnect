import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/utils/constants.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});
  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController   = TextEditingController();
  final _unitController  = TextEditingController();

  final _titleFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _qtyFocus   = FocusNode();
  final _unitFocus  = FocusNode();
  final _descFocus  = FocusNode();

  String _selectedCategory = 'Fresh Fish';
  String _selectedCurrency = 'INR';
  String _priceUnit = 'kg'; // kg, piece, lot, vessel, set
  bool _isLoading = false;
  String? _imageUrl; // URL field for now

  // Quick product suggestions grouped
  final Map<String, List<String>> _quickProducts = {
    '🐟 Seafood': ['Rohu Fish', 'Katla Fish', 'Pomfret', 'Hilsa', 'Tuna', 'Salmon', 'Mackerel', 'Sardine'],
    '🦐 Shellfish': ['Tiger Prawns', 'Lobster', 'Crab', 'Squid', 'Oysters', 'Clams', 'Mussels'],
    '⚓ Equipment': ['Fishing Net', 'Life Jacket', 'GPS Navigator', 'Anchor', 'Marine Rope', 'Echo Sounder'],
    '🚢 Vessels': ['Fishing Boat', 'Speed Boat', 'Trawler', 'Cargo Vessel'],
  };

  @override
  void dispose() {
    _titleController.dispose(); _descController.dispose();
    _priceController.dispose(); _qtyController.dispose();
    _unitController.dispose();
    _titleFocus.dispose(); _priceFocus.dispose();
    _qtyFocus.dispose(); _unitFocus.dispose(); _descFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      await FirebaseFirestore.instance.collection('listings').add({
        'sellerId': user.uid,
        'sellerName': userData['name'] ?? 'Unknown Seller',
        'sellerLocation': userData['location'] ?? '',
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'pricePerKg': double.tryParse(_priceController.text) ?? 0,
        'priceUnit': _priceUnit,
        'currency': _selectedCurrency,
        'quantityKg': double.tryParse(_qtyController.text) ?? 0,
        'quantityUnit': _unitController.text.trim().isEmpty ? _priceUnit : _unitController.text.trim(),
        'imageUrls': _imageUrl != null && _imageUrl!.isNotEmpty ? [_imageUrl!] : [],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Listing posted successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        title: const Text('Post a listing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [

            // Quick product selector
            ..._quickProducts.entries.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.value.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final product = entry.value[i];
                      final selected = _titleController.text == product;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _titleController.text = product;
                            // Auto-set category
                            final p = product.toLowerCase();
                            if (p.contains('boat') || p.contains('vessel') || p.contains('trawler')) _selectedCategory = 'Boats & Vessels';
                            else if (p.contains('net') || p.contains('rope') || p.contains('anchor') || p.contains('gear')) _selectedCategory = 'Fishing Gear';
                            else if (p.contains('jacket') || p.contains('gps') || p.contains('echo') || p.contains('navigator')) _selectedCategory = 'Navigation Tools';
                            else if (p.contains('prawn') || p.contains('lobster') || p.contains('crab') || p.contains('squid') || p.contains('oyster')) _selectedCategory = 'Prawns & Shrimp';
                            else _selectedCategory = 'Fresh Fish';
                            _priceUnit = (p.contains('boat') || p.contains('vessel')) ? 'vessel' : (p.contains('net') || p.contains('set')) ? 'set' : 'kg';
                          });
                          FocusScope.of(context).requestFocus(_priceFocus);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: selected ? t.primary.withOpacity(0.2) : t.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? t.primary : Colors.white.withOpacity(0.1))),
                          child: Center(child: Text(product, style: TextStyle(color: selected ? t.primary : Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.normal))),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],
            )),

            const SizedBox(height: 4),

            // Product image URL
            _label('Product photo (image URL)', t),
            const SizedBox(height: 6),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.next,
              onChanged: (v) => setState(() => _imageUrl = v.trim()),
              decoration: _inp('https://example.com/your-product-image.jpg', t),
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_titleFocus),
            ),

            // Image preview
            if (_imageUrl != null && _imageUrl!.startsWith('http')) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(_imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 60, color: t.card,
                    child: Center(child: Text('Invalid image URL', style: TextStyle(color: Colors.white.withOpacity(0.3)))))),
              ),
            ],

            const SizedBox(height: 16),

            // Product name
            _label('Product / Item name *', t),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController, focusNode: _titleFocus,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white),
              decoration: _inp('e.g. Fresh Tiger Prawns, Fishing Net 100m, GPS Navigator', t),
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_priceFocus),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),

            const SizedBox(height: 16),

            // Category
            _label('Category *', t),
            const SizedBox(height: 6),
            _dropdown(AppConstants.categories, _selectedCategory, t, (v) => setState(() => _selectedCategory = v!)),

            const SizedBox(height: 16),

            // Price + unit + currency
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Price *', t),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController, focusNode: _priceFocus,
                  keyboardType: TextInputType.number, textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inp('500', t),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_qtyFocus),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Per', t),
                const SizedBox(height: 6),
                _dropdown(['kg', 'piece', 'lot', 'vessel', 'set', 'litre'], _priceUnit, t, (v) => setState(() => _priceUnit = v!)),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Currency', t),
                const SizedBox(height: 6),
                _dropdown(AppConstants.currencies, _selectedCurrency, t, (v) => setState(() => _selectedCurrency = v!)),
              ])),
            ]),

            const SizedBox(height: 16),

            // Quantity
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Quantity available *', t),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _qtyController, focusNode: _qtyFocus,
                  keyboardType: TextInputType.number, textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inp('500', t),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_unitFocus),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Unit', t),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _unitController, focusNode: _unitFocus,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inp('kg', t),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descFocus)),
              ])),
            ]),

            const SizedBox(height: 16),

            // Description
            _label('Description (optional)', t),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController, focusNode: _descFocus,
              maxLines: 3, textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
              decoration: _inp('Condition, origin, delivery terms, special notes...', t),
              onFieldSubmitted: (_) => _submit()),

            const SizedBox(height: 32),

            SizedBox(width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.primary, foregroundColor: Colors.black,
                  disabledBackgroundColor: t.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Post listing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, AppTheme t) => Text(text,
    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600));

  InputDecoration _inp(String hint, AppTheme t) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
    filled: true, fillColor: t.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.primary, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    errorStyle: const TextStyle(color: Colors.redAccent));

  Widget _dropdown(List<String> items, String value, AppTheme t, void Function(String?) onChanged) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: value, isExpanded: true, dropdownColor: t.card,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.4), size: 18),
        items: items.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged)));
}