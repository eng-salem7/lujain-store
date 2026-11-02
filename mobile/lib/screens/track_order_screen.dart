import 'package:flutter/material.dart';
import '../core/constants.dart';

class TrackOrderScreen extends StatefulWidget {
  final String? initialOrderNum;

  const TrackOrderScreen({super.key, this.initialOrderNum});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  late final TextEditingController _controller;
  bool _hasSearched = false;

  final List<Map<String, String>> _timeline = [
    {'title': 'طلب جديد', 'subtitle': 'تم تسجيل طلبك في نظام متجر لجين', 'status': 'done'},
    {'title': 'قيد المراجعة', 'subtitle': 'فحص توفر المقاس واللون وتأكيد العنوان', 'status': 'done'},
    {'title': 'مقبول وقيد التجهيز', 'subtitle': 'تجهيز القطعة وتغليفها الفاخر وحجز المخزون', 'status': 'current'},
    {'title': 'جاهز للتسليم', 'subtitle': 'تم تسليم الشحنة لشركة التوصيل أو مندوب المتجر', 'status': 'pending'},
    {'title': 'خرج للتوصيل', 'subtitle': 'المندوب في طريقه لموقعك', 'status': 'pending'},
    {'title': 'مكتمل ومسلَّم', 'subtitle': 'تم تسليم الطلب واستلام المبلغ', 'status': 'pending'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialOrderNum ?? '');
    if (widget.initialOrderNum != null && widget.initialOrderNum!.isNotEmpty) {
      _hasSearched = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('تتبع مسار طلبك', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.beigeDark),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'أدخلي رقم الطلب (مثال: LUJ-2026-01001)',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() => _hasSearched = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('بحث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_hasSearched) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.beigeDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text(
                        _controller.text,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.beige,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: const Text(
                          'مقبول وقيد التجهيز',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Steps
                  Column(
                    children: _timeline.map((step) {
                      final isDone = step['status'] == 'done';
                      final isCurrent = step['status'] == 'current';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isDone
                                  ? AppColors.successGreen
                                  : isCurrent
                                      ? AppColors.gold
                                      : AppColors.beigeDark,
                              child: Icon(
                                isDone
                                    ? Icons.check
                                    : isCurrent
                                        ? Icons.hourglass_top
                                        : Icons.circle,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isCurrent ? AppColors.gold : AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    step['subtitle']!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
