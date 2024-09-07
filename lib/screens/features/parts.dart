import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekomarz/screens/features/parts-detail.dart';
import 'package:kekomarz/screens/features/product-card.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  _PartsScreenState createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref().child('Products');
  final DatabaseReference _cartsRef =
      FirebaseDatabase.instance.ref().child('Carts');
  final DatabaseReference _favoritesRef =
      FirebaseDatabase.instance.ref().child('Favorites');
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _addToCart(
    String productId,
    Map<dynamic, dynamic> productData,
  ) async {
    if (_user != null) {
      try {
        DatabaseReference cartRef =
            _cartsRef.child(_user!.uid).child(productId);
        DataSnapshot snapshot = await cartRef.get();

        if (snapshot.exists) {
          // Product is already in the cart
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product is already in the cart!')),
            );
          }
        } else {
          // Add the product to the cart with default quantity value 1
          Map<String, dynamic> productMap =
              Map<String, dynamic>.from(productData);
          productMap['quantity'] = 1; // Set default quantity
          await cartRef.set(productMap);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to Cart!')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error adding to cart')),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite(String productId,
      Map<dynamic, dynamic> productData, bool isFavorite) async {
    if (_user != null) {
      try {
        if (isFavorite) {
          // Remove from favorites
          await _favoritesRef.child(_user!.uid).child(productId).remove();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from Favorites!')),
          );
        } else {
          // Add to favorites
          Map<String, dynamic> productMap =
              Map<String, dynamic>.from(productData);
          await _favoritesRef
              .child(_user!.uid)
              .child(productId)
              .set(productMap);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to Favorites!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update favorites')),
          );
        }
      }
    }
  }

  void _navigateToDetails(String productId, Map<dynamic, dynamic> productData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartsDetailScreen(
          productId: productId,
          productName: productData['productName'],
          category: productData['category'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          price: productData['price'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 164, 212),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/images/kekomarz-logo.png',
              width: 120,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 100, 59, 159),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.search, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.robotoCondensed(color: Colors.white),
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or category',
                        hintStyle:
                            GoogleFonts.robotoCondensed(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: _productsRef.get(),
              builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading products',
                          style: GoogleFonts.robotoCondensed(
                              color: Colors.white)));
                } else if (snapshot.hasData) {
                  Map<dynamic, dynamic> products =
                      snapshot.data!.value as Map<dynamic, dynamic>;

                  var filteredProducts = products.entries.where((product) {
                    String name = product.value['productName'].toLowerCase();
                    String category = product.value['category'].toLowerCase();
                    return name.contains(_searchText) ||
                        category.contains(_searchText);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                        child: Text('No products found.',
                            style: GoogleFonts.robotoCondensed(
                                color: Colors.white)));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];
                      var productId = product.key;
                      var productData = product.value;

                      return ProductCard(
                        productId: productId,
                        category: productData['category'],
                        description: productData['description'],
                        imageUrl: productData['imageUrl'],
                        price: productData['price'],
                        productName: productData['productName'],
                        onAddToCart: () => _addToCart(productId, productData),
                        onToggleFavorite: (isFavorite) =>
                            _toggleFavorite(productId, productData, isFavorite),
                        favoritesRef: _favoritesRef,
                        userId: _user!.uid,
                        onViewDetails: () =>
                            _navigateToDetails(productId, productData),
                      );
                    },
                  );
                } else {
                  return Center(
                      child: Text('No products available.',
                          style: GoogleFonts.robotoCondensed(
                              color: Colors.white)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
