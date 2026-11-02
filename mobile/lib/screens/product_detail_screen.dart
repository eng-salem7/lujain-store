import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../core/constants.dart';
import '../providers/store_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductVariantModel _selectedVariant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.variants.first;
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          widget.product.nameAr,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Main Product Image
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.beige,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.images.isNotEmpty ? widget.product.images[0] : '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.nameAr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.product.effectivePrice.toInt()} ${AppConstants.currency}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                        if (widget.product.hasDiscount)
                          Text(
                            '${widget.product.basePrice.toInt()}',
                            style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Fabric Details Tag
                if (widget.product.fabricDetails != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.beige.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.beigeDark),
                    ),
                    child: Text(
                      'خامة القماش: ${widget.product.fabricDetails}',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                  ),

                const SizedBox(height: 16),

                // Description
                Text(
                  widget.product.descriptionAr,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
                ),

                const SizedBox(height: 20),

                // Color Selection
                const Text('اختاري اللون:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.product.variants.map((v) {
                    final isSelected = _selectedVariant.id == v.id;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(v.colorNameAr),
                      avatar: CircleAvatar(
                        radius: 8,
                        backgroundColor: _parseColor(v.colorHex),
                      ),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _selectedVariant = v),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Size Selection
                const Text('المقاس:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.product.variants.map((v) {
                    final isSelected = _selectedVariant.size == v.size;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(v.size),
                      selectedColor: AppColors.gold,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _selectedVariant = v),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Bottom Bar: Add to Cart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.beigeDark)),
            ),
            child: Row(
              children: [
                // Quantity Counter
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.beige,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                        icon: const Icon(Icons.remove, size: 18),
                      ),
                      Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add, size: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Add Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      store.addToCart(widget.product, _selectedVariant, quantity: _quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تمت إضافة المنتج إلى حقيبة التسوق بنجاح!'),
                          backgroundColor: AppColors.successGreen,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'إضافة إلى الحقيبة',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
