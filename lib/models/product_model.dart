class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
  final int sold;
  final String category;
  final String gender;
  final List<String> sizes;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.sold,
    required this.category,
    required this.gender,
    required this.sizes,
  });
}

class CartItem {
  final ProductModel product;
  int quantity;
  String selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedSize,
  });

  double get total => product.price * quantity;
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final double discountFee;
  final double deliveryFee;
  final double finalPrice;
  final String status; // 'need_to_pay', 'on_the_way', 'history'
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.discountFee,
    required this.deliveryFee,
    required this.finalPrice,
    required this.status,
    required this.createdAt,
  });
}
