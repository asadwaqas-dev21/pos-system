import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/settings_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_models.dart';
import 'models/order_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CartItemAdapter());
  Hive.registerAdapter(OrderModelAdapter());

  await Hive.openBox<OrderModel>('orders');
  await Hive.openBox<Product>('products');
  await Hive.openBox('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const POSApp(),
    ),
  );
}

class POSApp extends StatelessWidget {
  const POSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: settings.storeName,
          debugShowCheckedModeBanner: false,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const DashboardScreen(),
        );
      },
    );
  }
}
