import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'product': {
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'images': product.images,
          'category': product.category,
          'rating': product.rating,
        },
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final p = json['product'] as Map<String, dynamic>;
    final rawImages = p['images'];
    return CartItem(
      product: Product(
        id: p['id'] as int,
        name: p['name'] as String,
        price: (p['price'] as num).toDouble(),
        description: p['description'] as String? ?? '',
        imageUrl: p['imageUrl'] as String? ?? '',
        images: rawImages is List
            ? rawImages.map((e) => e.toString()).toList()
            : const [],
        category: p['category'] as String? ?? '',
        rating: (p['rating'] as num?)?.toDouble() ?? 0.0,
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class CartModel extends ChangeNotifier {
  static const String _storageKey = 'cart_items';

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(decoded
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      // Corrupt storage — ignore and start fresh
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void add(Product product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
    _save();
  }

  void removeOne(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index < 0) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
    _save();
  }

  void removeAll(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
    _save();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _save();
  }
}