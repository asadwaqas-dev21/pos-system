import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:pos_app/models/order_model.dart';
import 'package:pos_app/theme.dart';

class DailyActivitiesScreen extends StatefulWidget {
  final DateTime date;
  final VoidCallback onBack;

  const DailyActivitiesScreen({Key? key, required this.date, required this.onBack}) : super(key: key);

  @override
  State<DailyActivitiesScreen> createState() => _DailyActivitiesScreenState();
}

class _DailyActivitiesScreenState extends State<DailyActivitiesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(widget.date);
    
    return ValueListenableBuilder(
      valueListenable: Hive.box<OrderModel>('orders').listenable(),
      builder: (context, Box<OrderModel> box, _) {
        final allOrders = box.values.toList();
        
        var filteredOrders = allOrders.where((order) {
          return order.date.year == widget.date.year &&
                 order.date.month == widget.date.month &&
                 order.date.day == widget.date.day;
        }).toList();

        double totalSales = filteredOrders.fold(0, (sum, order) => sum + order.total);

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          filteredOrders = filteredOrders.where((order) {
            final customerMatch = (order.customerName ?? 'Walk-in Customer').toLowerCase().contains(query);
            final idMatch = order.orderId.toLowerCase().contains(query);
            return customerMatch || idMatch;
          }).toList();
        }
        
        filteredOrders.sort((a, b) => b.date.compareTo(a.date));


        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                      onPressed: widget.onBack,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Activities for $dateStr',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Sales: PKR ${totalSales.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'Orders: ${filteredOrders.length}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      ? const Center(child: Text("No activities found for this date."))
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final timeFormatted = DateFormat('hh:mm a').format(order.date);
                            final customerName = order.customerName?.isNotEmpty == true 
                                ? order.customerName! 
                                : 'Walk-in Customer';

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.withAlpha(50)),
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.successColor.withAlpha(25),
                                  child: const Icon(Icons.receipt_long, color: AppTheme.successColor),
                                ),
                                title: Text(
                                  '${order.orderId} • $customerName',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                subtitle: Text(
                                  timeFormatted,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: Text(
                                  'PKR ${order.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    color: Theme.of(context).colorScheme.surface,
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const Divider(),
                                        ...order.items.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${item.quantity}x ${item.product.name}'),
                                                Text('PKR ${item.totalPrice.toStringAsFixed(2)}'),
                                              ],
                                            ),
                                          );
                                        }).toList(),
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
}
