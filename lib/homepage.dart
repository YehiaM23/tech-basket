import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_product_screen.dart';
import 'product.dart';
import 'promo_banner.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, dynamic>> products = [
    {
      'image': 'images/iphone.png',
      'name': 'iPhone 17 Pro',
      'price': 999.0,
      'category': 'Phones',
      'isAsset': true,
      'favorite': false,
      'quantity': 0,
    },
    {
      'image': 'images/samsung.png',
      'name': 'Samsung S25',
      'price': 899.0,
      'category': 'Phones',
      'isAsset': true,
      'favorite': false,
      'quantity': 0,
    },
    {
      'image': 'images/anker.png',
      'name': 'Anker Charger',
      'price': 29.0,
      'category': 'Accessories',
      'isAsset': true,
      'favorite': false,
      'quantity': 0,
    },
    {
      'image': 'images/asus.png',
      'name': 'Asus Laptop',
      'price': 799.0,
      'category': 'Laptops',
      'isAsset': true,
      'favorite': false,
      'quantity': 0,
    },
  ];
  String search = '', category = 'All';
  int tab = 0;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('tech_basket_products_v1');
      if (saved != null) {
        products = (jsonDecode(saved) as List)
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
      }
    } catch (_) {
      /* Keep the starter catalog if local storage is unavailable. */
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(
        'tech_basket_products_v1',
        jsonEncode(products),
      );
      if (!ok) throw Exception('Storage unavailable');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save changes on this device.'),
          ),
        );
      }
    }
  }

  Future<void> addProduct() async {
    final product = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (!mounted || product == null) return;
    setState(() => products.add(product));
    await saveProducts();
  }

  @override
  Widget build(BuildContext context) {
    final visible = products
        .where(
          (p) =>
              (p['name'] as String).toLowerCase().contains(
                search.toLowerCase(),
              ) &&
              (category == 'All' || p['category'] == category) &&
              (tab != 1 || p['favorite'] == true) &&
              (tab != 2 || (p['quantity'] as int) > 0),
        )
        .toList();
    final total = products.fold<double>(
      0,
      (sum, p) => sum + (p['price'] as num) * (p['quantity'] as int),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Basket'),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: loading ? null : addProduct,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() {
          tab = v;
          search = '';
          category = 'All';
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (tab == 0)
                      PromoBanner(
                        onShop: (name) => setState(() => search = name),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      tab == 0
                          ? 'Find your next favorite.'
                          : tab == 1
                          ? 'Saved for later.'
                          : 'Your shopping bag.',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: ValueKey(tab),
                      onChanged: (v) => setState(() => search = v),
                      decoration: const InputDecoration(
                        hintText: 'Search products',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['All', 'Phones', 'Laptops', 'Accessories']
                          .map(
                            (c) => ChoiceChip(
                              label: Text(c),
                              selected: category == c,
                              onSelected: (_) => setState(() => category = c),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nothing here yet. Browse the shop or try a different search.',
                        ),
                      ),
                    for (final p in visible)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ProductCard(
                                image: p['image'] as String,
                                name: p['name'] as String,
                                price:
                                    '\$${(p['price'] as num).toStringAsFixed(2)}',
                                isAsset: p['isAsset'] as bool,
                                showHeart: true,
                                favorite: p['favorite'] as bool,
                                onHeartTap: () {
                                  setState(
                                    () => p['favorite'] =
                                        !(p['favorite'] as bool),
                                  );
                                  saveProducts();
                                },
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if ((p['quantity'] as int) > 0)
                                    IconButton(
                                      tooltip: 'Remove one',
                                      onPressed: () {
                                        setState(
                                          () => p['quantity'] =
                                              (p['quantity'] as int) - 1,
                                        );
                                        saveProducts();
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                  if ((p['quantity'] as int) > 0)
                                    Text('In cart: ${p['quantity']}'),
                                  FilledButton.icon(
                                    onPressed: () {
                                      setState(
                                        () => p['quantity'] =
                                            (p['quantity'] as int) + 1,
                                      );
                                      saveProducts();
                                    },
                                    icon: const Icon(Icons.add_shopping_cart),
                                    label: const Text('Add to cart'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (tab == 2) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: total <= 0
                            ? null
                            : () => showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Demo checkout'),
                                  content: Text(
                                    'Total: \$${total.toStringAsFixed(2)}\nNo payment will be taken.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        setState(() {
                                          for (final p in products) {
                                            p['quantity'] = 0;
                                          }
                                        });
                                        saveProducts();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Demo order complete. Your cart is now empty.',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Complete demo order'),
                                    ),
                                  ],
                                ),
                              ),
                        child: const Text('Review order'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
