import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/store_provider.dart';
import 'track_order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _streetController = TextEditingController();

  String _selectedCity = 'صنعاء';
  String _paymentMethod = 'cash_on_delivery';
  bool _isSubmitting = false;

  final Map<String, double> _cityFees = {
    'صنعاء': 2000.0,
    'عدن': 3500.0,
    'تعز': 3500.0,
    'حضرموت': 4000.0,
    'إب': 3000.0,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final deliveryFee = _cityFees[_selectedCity] ?? 2000.0;
    final total = store.cartTotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text('إتمام الطلب والتوصيل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.beigeDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('بيانات المستلمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى كتابة الاسم' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف / الواتساب *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى كتابة رقم الهاتف' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Shipping Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.beigeDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('عنوان التوصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(labelText: 'المحافظة', border: OutlineInputBorder()),
                    items: _cityFees.keys.map((city) {
                      return DropdownMenuItem(value: city, child: Text('$city (${_cityFees[city]!.toInt()} ر.ي)'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCity = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _areaController,
                    decoration: const InputDecoration(labelText: 'المنطقة / الحي *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى كتابة اسم الحي' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(labelText: 'تفاصيل الشارع والمنزل *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى كتابة تفاصيل الشارع' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Payment Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.beigeDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  RadioListTile<String>(
                    title: const Text('نقداً عند الاستلام', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('الدفع عند استلام الشحنة', style: TextStyle(fontSize: 11)),
                    value: 'cash_on_delivery',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  RadioListTile<String>(
                    title: const Text('بنك الكريمي (حاسب)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('حساب رقم: 30248911', style: TextStyle(fontSize: 11)),
                    value: 'kuraimi',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  RadioListTile<String>(
                    title: const Text('محفظة فلوسك (كريمي)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('رقم المحفظة: 770123456', style: TextStyle(fontSize: 11)),
                    value: 'floosak',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isSubmitting = true);

                        final orderNum = await store.submitOrder(
                          name: _nameController.text,
                          phone: _phoneController.text,
                          city: _selectedCity,
                          area: _areaController.text,
                          street: _streetController.text,
                          paymentMethod: _paymentMethod,
                          deliveryFee: deliveryFee,
                          discount: 0.0,
                        );

                        setState(() => _isSubmitting = false);

                        if (!mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            title: const Text('تم استلام طلبك بنجاح!'),
                            content: Text('رقم الطلب الخاص بكِ: $orderNum\nسيتم التواصل معك عبر الواتساب لتأكيد الشحن.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrackOrderScreen(initialOrderNum: orderNum),
                                    ),
                                  );
                                },
                                child: const Text('تتبع مسار الطلب'),
                              ),
                            ],
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'تأكيد الطلب الآن (${total.toInt()} ${AppConstants.currency})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
