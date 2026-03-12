import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:pos_app/models/order_model.dart';
import 'package:pos_app/theme.dart';

class CustomerStats {
  final String name;
  int totalOrders;
  double totalSpent;
  DateTime lastOrderDate;
  final List<OrderModel> history;

  CustomerStats({
    required this.name,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    required this.lastOrderDate,
    required this.history,
  });
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';

  List<CustomerStats> _aggregateCustomers(List<OrderModel> orders) {
    final Map<String, CustomerStats> customerMap = {};

    for (var order in orders) {
      final name = (order.customerName == null || order.customerName!.isEmpty)
          ? 'Walk-in Customer'
          : order.customerName!;

      if (!customerMap.containsKey(name)) {
        customerMap[name] = CustomerStats(
          name: name,
          lastOrderDate: order.date,
          history: [],
        );
      }

      final stats = customerMap[name]!;
      stats.totalOrders += 1;
      stats.totalSpent += order.total;
      stats.history.add(order);
      if (order.date.isAfter(stats.lastOrderDate)) {
        stats.lastOrderDate = order.date;
      }
    }

    final sortedCustomers = customerMap.values.toList()
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

    // Sort histories newer first
    for (var stats in sortedCustomers) {
      stats.history.sort((a, b) => b.date.compareTo(a.date));
    }

    return sortedCustomers;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<OrderModel>('orders').listenable(),
      builder: (context, Box<OrderModel> box, _) {
        final orders = box.values.toList();
        final allCustomers = _aggregateCustomers(orders);

        final customers = allCustomers
            .where((c) => c.name.toLowerCase().contains(_searchQuery))
            .toList();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search customers...',
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
                child: customers.isEmpty
                    ? const Center(
                        child: Text("No customers matched your search."),
                      )
                    : ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
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
                                backgroundColor: AppTheme.primaryColor
                                    .withAlpha(25),
                                child: Text(
                                  customer.name.characters.first.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              title: Text(
                                customer.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                '${customer.totalOrders} Orders • Total: PKR ${customer.totalSpent.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Purchase History',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...customer.history.map((order) {
                                        final timeFormatted = DateFormat(
                                          'MMM dd, yyyy - hh:mm a',
                                        ).format(order.date);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(timeFormatted),
                                              Text(
                                                order.orderId,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                'PKR ${order.total.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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
