import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:pos_app/models/order_model.dart';
import 'package:pos_app/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<OrderModel>('orders').listenable(),
      builder: (context, Box<OrderModel> box, _) {
        final allOrders = box.values.toList();

        // Sort newest first
        allOrders.sort((a, b) => b.date.compareTo(a.date));

        final filteredOrders = allOrders.where((order) {
          final query = _searchQuery.toLowerCase();
          final customerMatch = (order.customerName ?? 'Walk-in Customer')
              .toLowerCase()
              .contains(query);
          final idMatch = order.orderId.toLowerCase().contains(query);
          return customerMatch || idMatch;
        }).toList();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales History',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  if (filteredOrders.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _confirmDeleteAll(box),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Clear All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.15),
                        foregroundColor: Colors.red,
                        elevation: 0,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Order ID or Customer Name...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Center(child: Text("No sales history found."))
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final timeFormatted = DateFormat(
                            'MMM dd, yyyy - hh:mm a',
                          ).format(order.date);
                          final customerName =
                              order.customerName?.isNotEmpty == true
                              ? order.customerName!
                              : 'Walk-in Customer';

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.grey.withAlpha(50),
                              ),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.successColor
                                    .withAlpha(25),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: AppTheme.successColor,
                                ),
                              ),
                              title: Text(
                                '${order.orderId} • $customerName',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                timeFormatted,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'PKR ${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDeleteOrdeR(order),
                                    tooltip: 'Delete Order',
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Theme.of(context).colorScheme.surface,
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Order Details',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider(),
                                      ...order.items.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${item.quantity}x ${item.product.name}',
                                              ),
                                              Text(
                                                'PKR ${item.totalPrice.toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Subtotal:'),
                                          Text(
                                            'PKR ${order.subtotal.toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Tax:'),
                                          Text(
                                            'PKR ${order.tax.toStringAsFixed(2)}',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteOrdeR(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
          'Are you sure you want to delete order ${order.orderId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              order.delete();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(Box<OrderModel> box) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all sales history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              box.clear();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
