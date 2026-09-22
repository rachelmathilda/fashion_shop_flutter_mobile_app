import 'product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;
  final String selectedSize;

  CartItem({required this.product, this.quantity = 1, this.selectedSize = 'M'});

  num get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity, String? selectedSize}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'selectedSize': selectedSize,
    };
  }
}
