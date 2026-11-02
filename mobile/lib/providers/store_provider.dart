import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../core/supabase_config.dart';

class StoreProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  final List<CartItemModel> _cart = [];
  final Set<String> _wishlist = {};
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<CartItemModel> get cart => _cart;
  Set<String> get wishlist => _wishlist;
  bool get isLoading => _isLoading;

  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  StoreProvider() {
    loadInitialData();
  }

  void loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    // Check Supabase first
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final catRes = await client.from('categories').select().eq('is_active', true);
        if (catRes.isNotEmpty) {
          _categories = (catRes as List).map((c) => CategoryModel.fromJson(c)).toList();
        }

        final prodRes = await client.from('products').select('''
          *,
          images:product_images(*),
          variants:product_variants(*)
        ''').eq('is_active', true);

        if (prodRes.isNotEmpty) {
          _products = (prodRes as List).map((p) => ProductModel.fromJson(p)).toList();
        }
      } catch (e) {
        // Fallback to local default data
      }
    }

    // Default Seed Data if Supabase is not yet populated
    if (_categories.isEmpty) {
      _categories = [
        CategoryModel(id: 'ca1', nameAr: 'فساتين سهرة', nameEn: 'Dresses', slug: 'dresses', imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&q=80'),
        CategoryModel(id: 'ca2', nameAr: 'جلابيات وعبايات', nameEn: 'Jalabiyas', slug: 'jalabiyas', imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&q=80'),
        CategoryModel(id: 'ca3', nameAr: 'أطقم راقية', nameEn: 'Sets', slug: 'sets', imageUrl: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&q=80'),
        CategoryModel(id: 'ca4', nameAr: 'بلايز وقمصان', nameEn: 'Blouses', slug: 'blouses', imageUrl: 'https://images.unsplash.com/photo-1608234808654-2a8875faa7fd?w=800&q=80'),
        CategoryModel(id: 'ca5', nameAr: 'تنانير وبناطيل', nameEn: 'Pants', slug: 'pants', imageUrl: 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&q=80'),
      ];
    }

    if (_products.isEmpty) {
      _products = [
        ProductModel(
          id: 'p1',
          categoryId: 'ca1',
          nameAr: 'فستان لجين المخملي الفاخر بتطريز ذهبي',
          nameEn: 'Lujain Velvet Luxury Evening Gown',
          slug: 'lujain-velvet',
          descriptionAr: 'فستان سهرة استثنائي مصمم من المخمل الكوري الفاخر مع لمسات تطريز يدوي بخيوط ذهبية هادئة وقصة تبرز القوام برقي وأناقة، مبطن بالكامل بالحرير الناعم.',
          basePrice: 48000,
          discountPrice: 42000,
          fabricDetails: 'مخمل كوري فاخر مبطن بحرير ساتان',
          isFeatured: true,
          images: [
            'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800&q=80',
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&q=80'
          ],
          variants: [
            ProductVariantModel(id: 'v1', productId: 'p1', sku: 'LUJ-DRS-01-NAVY-M', colorNameAr: 'كحلي ملكي', colorNameEn: 'Royal Navy', colorHex: '#1A2A44', size: 'M', stock: 8),
            ProductVariantModel(id: 'v2', productId: 'p1', sku: 'LUJ-DRS-01-NAVY-L', colorNameAr: 'كحلي ملكي', colorNameEn: 'Royal Navy', colorHex: '#1A2A44', size: 'L', stock: 5),
            ProductVariantModel(id: 'v3', productId: 'p1', sku: 'LUJ-DRS-01-BUR-M', colorNameAr: 'عنابي دافئ', colorNameEn: 'Burgundy', colorHex: '#6B1D2F', size: 'M', stock: 12),
          ],
        ),
        ProductModel(
          id: 'p2',
          categoryId: 'ca2',
          nameAr: 'جلابية ريم الرمضانية بالعاجي والبيج',
          nameEn: 'Reem Luxury Cream Jalabiya',
          slug: 'reem-jalabiya',
          descriptionAr: 'جلابية ملكية باللون العاجي المميز تجمع بين الأصالة والعصرية مع نقوش تطريز عربية متقنة وأكمام كلوش انسيابية خفيفة وباردة.',
          basePrice: 32000,
          discountPrice: 28500,
          fabricDetails: 'كتان طبيعي مخلوط بالحرير البارد',
          isFeatured: true,
          images: [
            'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&q=80'
          ],
          variants: [
            ProductVariantModel(id: 'v4', productId: 'p2', sku: 'LUJ-JAL-02-CRM-FREE', colorNameAr: 'عاجي كريمي', colorNameEn: 'Ivory Cream', colorHex: '#FAF5EE', size: 'Free Size', stock: 15),
          ],
        ),
        ProductModel(
          id: 'p3',
          categoryId: 'ca3',
          nameAr: 'طقم كلاسيك راقي (بليزر وبنطال قماش واسع)',
          nameEn: 'Classic Elegant Two-Piece Suit',
          slug: 'classic-suit',
          descriptionAr: 'طقم نسائي متميز يتكون من بليزر رسمي بأزرار مزدوجة مغطاة بنفس القماش مع بنطال واسع مريح، يمنحك حضوراً رسمياً واثقاً.',
          basePrice: 39000,
          discountPrice: 34000,
          fabricDetails: 'كريب تركي عالي الجودة مقاوم للتجعد',
          isFeatured: true,
          images: [
            'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&q=80'
          ],
          variants: [
            ProductVariantModel(id: 'v5', productId: 'p3', sku: 'LUJ-SET-03-BGE-M', colorNameAr: 'بيج كابتشينو', colorNameEn: 'Beige Cappuccino', colorHex: '#C8B29B', size: 'M', stock: 9),
          ],
        ),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  void addToCart(ProductModel product, ProductVariantModel variant, {int quantity = 1}) {
    final existingIndex = _cart.indexWhere((item) => item.variant.id == variant.id);
    if (existingIndex > -1) {
      _cart[existingIndex].quantity += quantity;
    } else {
      _cart.add(CartItemModel(product: product, variant: variant, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String variantId) {
    _cart.removeWhere((item) => item.variant.id == variantId);
    notifyListeners();
  }

  void updateQuantity(String variantId, int newQty) {
    if (newQty <= 0) {
      removeFromCart(variantId);
    } else {
      final index = _cart.indexWhere((item) => item.variant.id == variantId);
      if (index > -1) {
        _cart[index].quantity = newQty;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void toggleWishlist(String productId) {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    notifyListeners();
  }

  bool isInWishlist(String productId) => _wishlist.contains(productId);

  Future<String> submitOrder({
    required String name,
    required String phone,
    required String city,
    required String area,
    required String street,
    required String paymentMethod,
    required double deliveryFee,
    required double discount,
  }) async {
    final orderNum = 'LUJ-2026-${10000 + DateTime.now().millisecond}';
    final total = cartTotal + deliveryFee - discount;

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.from('orders').insert({
          'order_number': orderNum,
          'guest_name': name,
          'guest_phone': phone,
          'delivery_type': 'home_delivery',
          'shipping_address_snapshot': {
            'city': city,
            'area': area,
            'street_details': street,
          },
          'subtotal': cartTotal,
          'delivery_fee': deliveryFee,
          'discount_amount': discount,
          'total_amount': total,
          'status': 'new',
          'source': 'android',
        });
      } catch (e) {
        // Fallback
      }
    }

    clearCart();
    return orderNum;
  }
}
