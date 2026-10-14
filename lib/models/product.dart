class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final List<String> images;
  final String category;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final imagesList = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : <String>[];

    return Product(
      id: json['id'] as int,
      name: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      imageUrl: json['thumbnail'] as String,
      images: imagesList,
      category: json['category'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}