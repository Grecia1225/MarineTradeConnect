import 'package:flutter/material.dart';
import 'package:mtc/models/listing.dart';

class CartItem {
  final Listing listing;
  double quantity;
  CartItem({required this.listing, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  int get count => _items.length;
  double get total => _items.fold(0, (sum, i) => sum + (i.listing.pricePerKg * i.quantity));

  void add(Listing listing) {
    final idx = _items.indexWhere((i) => i.listing.id == listing.id);
    if (idx >= 0) {
      _items[idx].quantity += 1;
    } else {
      _items.add(CartItem(listing: listing));
    }
    notifyListeners();
  }

  void remove(String listingId) {
    _items.removeWhere((i) => i.listing.id == listingId);
    notifyListeners();
  }

  void updateQty(String listingId, double qty) {
    final idx = _items.indexWhere((i) => i.listing.id == listingId);
    if (idx >= 0) { _items[idx].quantity = qty; notifyListeners(); }
  }

  void clear() { _items.clear(); notifyListeners(); }
}