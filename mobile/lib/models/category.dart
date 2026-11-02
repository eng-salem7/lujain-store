class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String? imageUrl;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    this.imageUrl,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['image_url'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}
