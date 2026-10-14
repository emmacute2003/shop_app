import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';

class WishlistModel extends ChangeNotifier {
  static const String _storageKey = 'wishlist_items';

  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool get isEmpty => _items.isEmpty;

  bool isFavorite(Product product) {
    return _items.any((p) => p.id == product.id);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(decoded.map((e) {
          final p = e as Map<String, dynamic>;
          final rawImages = p['images'];
          return Product(
            id: p['id'] as int,
            name: p['name'] as String,
            price: (p['price'] as num).toDouble(),
            description: p['description'] as String? ?? '',
            imageUrl: p['imageUrl'] as String? ?? '',
            images: rawImages is List
                ? rawImages.map((im) => im.toString()).toList()
                : const [],
            category: p['category'] as String? ?? '',
            rating: (p['rating'] as num?)?.toDouble() ?? 0.0,
          );
        }));
      notifyListeners();
    } catch (_) {
      // Corrupt storage — ignore
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'price': p.price,
              'description': p.description,
              'imageUrl': p.imageUrl,
              'images': p.images,
              'category': p.category,
              'rating': p.rating,
            })
        .toList());
    await prefs.setString(_storageKey, encoded);
  }

  void toggle(Product product) {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    notifyListeners();
    _save();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _save();
  }
}