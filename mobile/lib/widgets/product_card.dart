import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../core/constants.dart';
import '../providers/store_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isWish = store.isInWishlist(product.id);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.beigeDark.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Box
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: product.images.isNotEmpty ? product.images[0] : '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(color: AppColors.beige),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.beige,
                        child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                      ),
                    ),
                  ),

                  // Discount Badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.discountRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'خصم ${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: InkWell(
                      onTap: () => store.toggleWishlist(product.id),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withOpacity(0.85),
                        child: Icon(
                          isWish ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isWish ? AppColors.discountRed : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product.effectivePrice.toInt()} ${AppConstants.currency}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${product.basePrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
