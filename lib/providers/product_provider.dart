import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/cart_models.dart';

class ProductProvider extends ChangeNotifier {
  final Box<Product> _productBox = Hive.box<Product>('products');

  List<Product> get products => _productBox.values.toList();

  ProductProvider() {
    _initInitialData();
  }

  void _initInitialData() {
    if (_productBox.isEmpty) {
      final initialProducts = [
        Product(id: 'p1', name: 'Fresh Milk 1L', price: 2.50),
        Product(id: 'p2', name: 'Whole Wheat Bread', price: 1.80),
        Product(id: 'p3', name: 'Organic Eggs (12)', price: 4.20),
        Product(id: 'p4', name: 'Premium Coffee 500g', price: 8.90),
        Product(id: 'p5', name: 'Rice 5kg bag', price: 7.50),
        Product(id: 'p6', name: 'Olive Oil 1L', price: 6.40),
      ];

      for (var p in initialProducts) {
        _productBox.put(p.id, p);
      }
    }
  }

  Future<void> addProduct(Product product) async {
    await _productBox.put(product.id, product);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _productBox.delete(id);
    notifyListeners();
  }
}
