import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_models.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({Key? key}) : super(key: key);

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _gstController = TextEditingController(text: '5');

  @override
  void dispose() {
    _customerNameController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          return isMobile ? _buildMobileView(context) : _buildDesktopView(context);
        },
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildProductGrid(context)),
        _buildCartSidebar(context, isMobile: true),
      ],
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: _buildProductGrid(context),
        ),
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(
          flex: 3,
          child: _buildCartSidebar(context, isMobile: false),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan'),
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search products by name or barcode... (or speak: "Rice 2")',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.mic, color: AppTheme.primaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: products.isEmpty 
                  ? const Center(child: Text("No products found."))
                  : GridView.builder(
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final prod = products[index];
                        return _buildProductCard(context, prod);
                      },
                    ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      child: InkWell(
        onTap: () {
          Provider.of<CartProvider>(context, listen: false).addItem(product);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                'PKR ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSidebar(BuildContext context, {required bool isMobile}) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();

    return Container(
      color: Colors.white,
      height: isMobile ? 300 : double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => cart.clearCart(),
                  tooltip: 'Clear Cart',
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('Cart is empty', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return ListTile(
                        title: Text(item.product.name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                          'PKR ${item.product.price.toStringAsFixed(2)}',
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cart.decrementQuantity(item.product.id),
                              color: Colors.grey[600],
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => cart.addItem(item.product),
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          _buildCartSummary(context, cart),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cart) {
    final double gstPercentage = double.tryParse(_gstController.text) ?? 0.0;
    final double taxRate = gstPercentage / 100.0;
    final subtotal = cart.totalAmount;
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _customerNameController,
            decoration: InputDecoration(
              hintText: 'Customer Name (Optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text('PKR ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('GST (%)', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _gstController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
              Text('PKR ${tax.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                'PKR ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: total > 0 ? () async {
                final customerName = _customerNameController.text.trim();
                await cart.checkout(taxRate, customerName: customerName.isNotEmpty ? customerName : null);
                _customerNameController.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase Complete & Receipt Printing!')),
                  );
                }
              } : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('Checkout Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
