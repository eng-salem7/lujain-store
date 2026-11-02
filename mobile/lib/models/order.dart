class CartItemModel {
  final ProductModel product;
  final ProductVariantModel variant;
  int quantity;

  CartItemModel({
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  double get totalPrice => (product.discountPrice ?? product.basePrice) * quantity;
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String guestName;
  final String guestPhone;
  final String city;
  final String area;
  final String streetDetails;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.guestName,
    required this.guestPhone,
    required this.city,
    required this.area,
    required this.streetDetails,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });
}
