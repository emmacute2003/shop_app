import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  /// Fetches every product from DummyJSON (limit=0 returns all ~194).
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products?limit=0'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode})');
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> rawProducts = body['products'] as List<dynamic>;

    return rawProducts
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}