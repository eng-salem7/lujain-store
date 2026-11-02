class ProductVariantModel {
  final String id;
  final String productId;
  final String sku;
  final String colorNameAr;
  final String colorNameEn;
  final String colorHex;
  final String size;
  final double additionalPrice;
  final double costPrice;
  final int stock;

  ProductVariantModel({
    required this.id,
    required this.productId,
    required this.sku,
    required this.colorNameAr,
    required this.colorNameEn,
    required this.colorHex,
    required this.size,
    this.additionalPrice = 0.0,
    this.costPrice = 0.0,
    this.stock = 10,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      sku: json['sku'] ?? '',
      colorNameAr: json['color_name_ar'] ?? '',
      colorNameEn: json['color_name_en'] ?? '',
      colorHex: json['color_hex'] ?? '#342419',
      size: json['size'] ?? 'M',
      additionalPrice: (json['additional_price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['cost_price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 10,
    );
  }
}

class ProductModel {
  final String id;
  final String categoryId;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String descriptionAr;
  final double basePrice;
  final double? discountPrice;
  final String? fabricDetails;
  final bool isFeatured;
  final bool isNew;
  final List<String> images;
  final List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    required this.descriptionAr,
    required this.basePrice,
    this.discountPrice,
    this.fabricDetails,
    this.isFeatured = false,
    this.isNew = true,
    required this.images,
    required this.variants,
  });

  double get effectivePrice => discountPrice ?? basePrice;

  bool get hasDiscount => discountPrice != null && discountPrice! < basePrice;

  int get discountPercent => hasDiscount
      ? (((basePrice - discountPrice!) / basePrice) * 100).round()
      : 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var rawImages = json['images'] as List? ?? [];
    List<String> imageList = rawImages.map((img) {
      if (img is Map) return img['image_url']?.toString() ?? '';
      return img.toString();
    }).where((s) => s.isNotEmpty).toList();

    var rawVariants = json['variants'] as List? ?? [];
    List<ProductVariantModel> variantList = rawVariants
        .map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
        .toList();

    return ProductModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      slug: json['slug'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      fabricDetails: json['fabric_details'],
      isFeatured: json['is_featured'] ?? false,
      isNew: json['is_new'] ?? true,
      images: imageList,
      variants: variantList,
    );
  }
}
