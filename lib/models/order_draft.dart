import '../models/cart_item_model.dart';
import '../models/coupon_model.dart';

class OrderDraft {
  final List<CartItem> items;
  final CouponModel? coupon;
  String addressText;
  double? addressLat;
  double? addressLng;
  num deliveryFee;

  OrderDraft({
    required this.items,
    this.coupon,
    this.addressText = '',
    this.addressLat,
    this.addressLng,
    this.deliveryFee = 0,
  });

  num get subtotal => items.fold<num>(0, (sum, i) => sum + i.subtotal);

  num get discountAmount {
    if (coupon == null) return 0;
    if (subtotal < coupon!.minTransaction) return 0;
    return subtotal * coupon!.percent / 100;
  }

  num get total => subtotal - discountAmount + deliveryFee;

  OrderDraft copyWith({
    CouponModel? coupon,
    String? addressText,
    double? addressLat,
    double? addressLng,
    num? deliveryFee,
  }) {
    return OrderDraft(
      items: items,
      coupon: coupon ?? this.coupon,
      addressText: addressText ?? this.addressText,
      addressLat: addressLat ?? this.addressLat,
      addressLng: addressLng ?? this.addressLng,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }
}
