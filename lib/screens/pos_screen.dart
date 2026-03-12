import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/models/cart_models.dart';
import 'package:pos_app/providers/cart_provider.dart';
import 'package:pos_app/providers/product_provider.dart';
import 'package:pos_app/providers/settings_provider.dart';
import 'package:pos_app/theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class POSScreen extends StatefulWidget {
  const POSScreen({Key? key}) : super(key: key);

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  late TextEditingController _gstController;
  late TextEditingController _searchController;
  String _searchQuery = '';
  
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _gstController = TextEditingController(
      text: settings.defaultTaxRate.toString(),
    );
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _gstController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            _searchQuery = val.recognizedWords.toLowerCase();
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          return isMobile
              ? _buildMobileView(context)
              : _buildDesktopView(context);
        },
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildProductList(context)),
        _buildCartSidebar(context, isMobile: true),
      ],
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 7, child: _buildProductList(context)),
        Container(width: 1, color: Colors.grey.shade300),
        Expanded(flex: 3, child: _buildCartSidebar(context, isMobile: false)),
      ],
    );
  }

  Widget _buildProductList(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products
            .where((p) => p.name.toLowerCase().contains(_searchQuery))
            .toList();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products by name... (or speak: "Rice")',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : AppTheme.primaryColor,
                    ),
                    onPressed: _listen,
                  ),
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
                child: products.isEmpty
                    ? const Center(child: Text("No products found."))
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final prod = products[index];
                          return _buildProductTile(context, prod);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(50)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'PKR ${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontSize: 15,
            ),
          ),
        ),
        trailing: OutlinedButton.icon(
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false).addItem(product);
          },
          icon: const Icon(Icons.add_shopping_cart, size: 18),
          label: const Text('Add'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        onTap: () {
          Provider.of<CartProvider>(context, listen: false).addItem(product);
        },
      ),
    );
  }

  Widget _buildCartSidebar(BuildContext context, {required bool isMobile}) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: isMobile ? 300 : double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
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
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Cart is empty',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return ListTile(
                        title: Text(
                          item.product.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          'PKR ${item.product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  cart.decrementQuantity(item.product.id),
                              color: Colors.grey[600],
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _customerNameController,
            decoration: InputDecoration(
              hintText: 'Customer Name (Required)',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text(
                'PKR ${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'PKR ${tax.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'PKR ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: total > 0
                  ? () async {
                      final customerName = _customerNameController.text.trim();
                      if (customerName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a customer name!'),
                          ),
                        );
                        return;
                      }
                      await cart.checkout(taxRate, customerName: customerName);
                      _customerNameController.clear();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Purchase Complete & Receipt Printing!',
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text(
                'Checkout Pay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
