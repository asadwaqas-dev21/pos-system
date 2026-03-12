import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/models/cart_models.dart';
import 'package:pos_app/providers/product_provider.dart';
import 'package:pos_app/theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final allProducts = provider.products;
        final products = allProducts
            .where((p) => p.name.toLowerCase().contains(_searchQuery))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Products'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text('No products available.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                'PKR ${product.price.toStringAsFixed(2)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () {
                                      _showEditProductDialog(
                                        context,
                                        provider,
                                        product,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      provider.deleteProduct(product.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddProductDialog(context, provider),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context, ProductProvider provider) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              if (name.isNotEmpty && price > 0) {
                final id = 'p_${DateTime.now().millisecondsSinceEpoch}';
                provider.addProduct(Product(id: id, name: name, price: price));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(
    BuildContext context,
    ProductProvider provider,
    Product product,
  ) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              if (name.isNotEmpty && price > 0) {
                provider.addProduct(
                  Product(id: product.id, name: name, price: price),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
