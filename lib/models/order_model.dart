import 'package:hive/hive.dart';
import 'cart_models.dart';

part 'order_model.g.dart';

@HiveType(typeId: 2)
class OrderModel extends HiveObject {
  @HiveField(0)
  final String orderId;

  @HiveField(1)
  final List<CartItem> items;

  @HiveField(2)
  final double subtotal;

  @HiveField(3)
  final double tax;

  @HiveField(4)
  final double total;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? customerName;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.date,
    this.customerName,
  });
}
