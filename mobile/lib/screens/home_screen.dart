import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';
import '../providers/store_provider.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
            Text(
              AppConstants.appSlogan,
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: store.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : RefreshIndicator(
              onRefresh: () async => store.loadInitialData(),
              color: AppColors.gold,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Promotional Hero Banner
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 16,
                          top: 24,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'تشكيلة 2026 الحصرية',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'أناقتك تبدأ من هنا',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'خصم 10% بكود LUJAIN10',
                                style: TextStyle(color: AppColors.goldLight, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Categories Horizontal Bar
                  const Text(
                    'أقسام التشكيلة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: store.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = store.categories[index];
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.beige,
                              backgroundImage: cat.imageUrl != null
                                  ? CachedNetworkImageProvider(cat.imageUrl!)
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.nameAr,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Products Grid Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text(
                        'الأكثر طلباً ومميز',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      Text(
                        'عرض الكل (${store.products.length})',
                        style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Products Grid
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: store.products.length,
                    itemBuilder: (context, index) {
                      return ProductCardWidget(product: store.products[index]);
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
