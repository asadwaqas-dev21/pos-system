import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:pos_app/widgets/stat_card.dart';
import 'package:pos_app/theme.dart';
import 'package:pos_app/models/order_model.dart';
import 'package:pos_app/screens/pos_screen.dart';
import 'package:pos_app/screens/products_screen.dart';
import 'package:pos_app/screens/customers_screen.dart';
import 'package:pos_app/screens/reports_screen.dart';
import 'package:pos_app/screens/calendar_screen.dart';
import 'package:pos_app/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard_rounded, 'title': 'Dashboard'},
    {'icon': Icons.point_of_sale_rounded, 'title': 'POS Cart'},
    {'icon': Icons.inventory_2_rounded, 'title': 'Products'},
    {'icon': Icons.people_alt_rounded, 'title': 'Customers'},
    {'icon': Icons.receipt_long_rounded, 'title': 'Reports'},
    {'icon': Icons.calendar_month_rounded, 'title': 'Calendar'},
    {'icon': Icons.settings_rounded, 'title': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final isTablet =
            constraints.maxWidth > 600 && constraints.maxWidth <= 900;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text('POS System'),
                  elevation: 0,
                ),
          drawer: !isDesktop
              ? Drawer(child: _buildSideMenu(isMobile: true))
              : null,
          body: Row(
            children: [
              if (isDesktop)
                SizedBox(width: 250, child: _buildSideMenu(isMobile: false)),
              if (isTablet)
                NavigationRail(
                  backgroundColor: const Color(0xFF1E1E2D),
                  unselectedIconTheme: const IconThemeData(
                    color: Colors.white54,
                  ),
                  selectedIconTheme: const IconThemeData(
                    color: AppTheme.primaryColor,
                  ),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (idx) {
                    setState(() {
                      _selectedIndex = idx;
                    });
                  },
                  labelType: NavigationRailLabelType.none,
                  destinations: _menuItems.map((item) {
                    return NavigationRailDestination(
                      icon: Icon(item['icon'] as IconData),
                      label: Text(item['title'] as String),
                    );
                  }).toList(),
                ),
              Expanded(child: _buildMainContent()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideMenu({required bool isMobile}) {
    const sidebarColor = Color(0xFF1E1E2D);

    return Container(
      color: sidebarColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.watch<SettingsProvider>().storeName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    tileColor: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (isMobile) {
                        Navigator.pop(context); // Close Drawer
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedIndex == 1) {
      return const POSScreen();
    }
    if (_selectedIndex == 2) {
      return const ProductsScreen();
    }
    if (_selectedIndex == 3) {
      return const CustomersScreen();
    }
    if (_selectedIndex == 4) {
      return const ReportsScreen();
    }
    if (_selectedIndex == 5) {
      return const CalendarScreen();
    }
    if (_selectedIndex == 6) {
      return const SettingsScreen();
    }

    // Default to Dashboard stats
    return ValueListenableBuilder(
      valueListenable: Hive.box<OrderModel>('orders').listenable(),
      builder: (context, Box<OrderModel> box, _) {
        final orders = box.values.toList();

        final double totalRevenue = orders.fold(
          0,
          (sum, order) => sum + order.total,
        );
        final int totalOrders = orders.length;

        // Calculate Today's Sales
        final today = DateTime.now();
        final double todaysSales = orders
            .where((order) {
              return order.date.year == today.year &&
                  order.date.month == today.month &&
                  order.date.day == today.day;
            })
            .fold(0, (sum, order) => sum + order.total);

        // Advanced Analytics
        final double avgOrderValue = totalOrders > 0
            ? (totalRevenue / totalOrders)
            : 0.0;

        // Sort orders chronologically (newest first)
        orders.sort((a, b) => b.date.compareTo(a.date));
        final recentOrders = orders.take(5).toList();

        return SingleChildScrollView(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 4;
                    if (constraints.maxWidth < 600) {
                      crossAxisCount = 1;
                    } else if (constraints.maxWidth < 1100) {
                      crossAxisCount = 2;
                    }

                    return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 2.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: "Today's Sales",
                          value: "PKR ${todaysSales.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                          color: AppTheme.primaryColor,
                        ),
                        StatCard(
                          title: "Total Orders",
                          value: "$totalOrders",
                          icon: Icons.shopping_basket_rounded,
                          color: AppTheme.accentColor,
                        ),
                        StatCard(
                          title: "Avg Order Value",
                          value: "PKR ${avgOrderValue.toStringAsFixed(2)}",
                          icon: Icons.analytics_rounded,
                          color: AppTheme.warningColor,
                        ),
                        StatCard(
                          title: "Total Revenue",
                          value: "PKR ${totalRevenue.toStringAsFixed(2)}",
                          icon: Icons.trending_up_rounded,
                          color: AppTheme.successColor,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      recentOrders.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  "No transactions yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recentOrders.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final order = recentOrders[index];
                                final timeFormatted = DateFormat(
                                  'MMM dd, hh:mm a',
                                ).format(order.date);

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.receipt,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    order.orderId,
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  subtitle: Text('Cash Sale • $timeFormatted'),
                                  trailing: Text(
                                    'PKR ${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
