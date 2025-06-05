class Plant {
  final String id;
  final String name;
  final String? scientificName;
  final String? category;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;

  Plant({
    required this.id,
    required this.name,
    this.scientificName,
    this.category,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
  });

  factory Plant.fromMap(Map<String, dynamic> map) => Plant(
    id: map['id'],
    name: map['name'],
    scientificName: map['scientific_name'],
    category: map['category'],
    price: double.tryParse(map['price'].toString()) ?? 0,
    stock: map['stock'],
    description: map['description'],
    imageUrl: map['image_url'],
  );
}

