import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/cart_models.dart';
import '../models/order_model.dart';
import '../services/pdf_service.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Increase quantity
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // Add new item to cart
      _items.putIfAbsent(product.id, () => CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> checkout(double taxRate, {String? customerName}) async {
    if (_items.isEmpty) return;

    final subtotal = totalAmount;
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    final order = OrderModel(
      orderId: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      items: _items.values.toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      date: DateTime.now(),
      customerName: customerName,
    );

    // Save offline using Hive
    final box = Hive.box<OrderModel>('orders');
    await box.add(order);

    // Trigger PDF printing
    await PdfService.printReceipt(order);

    clearCart();
  }
}
