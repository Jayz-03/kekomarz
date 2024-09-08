import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekomarz/screens/features/parts-detail.dart';
import 'package:kekomarz/screens/features/product-card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseReference _favoritesRef =
      FirebaseDatabase.instance.ref().child('Favorites');
  final DatabaseReference _cartsRef =
      FirebaseDatabase.instance.ref().child('Carts');
  User? _user;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product is already in the cart!')),
            );
          }
        } else {
          Map<String, dynamic> productMap =
              Map<String, dynamic>.from(productData);
          productMap['quantity'] = 1;
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
          await _favoritesRef.child(_user!.uid).child(productId).remove();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from Favorites!')),
            );
          }
        } else {
          Map<String, dynamic> productMap =
              Map<String, dynamic>.from(productData);
          await _favoritesRef
              .child(_user!.uid)
              .child(productId)
              .set(productMap);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to Favorites!')),
            );
          }
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
      body: _user == null
          ? const Center(
              child: Text('Please log in to see your favorites'),
            )
          : Column(
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
                            style: GoogleFonts.robotoCondensed(
                                color: Colors.white),
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name or category',
                              hintStyle: GoogleFonts.robotoCondensed(
                                  color: Colors.white),
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
                  child: StreamBuilder(
                    stream: _favoritesRef.child(_user!.uid).onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading favorites'));
                      } else if (snapshot.hasData) {
                        DataSnapshot dataSnapshot = snapshot.data!.snapshot;
                        Map<dynamic, dynamic>? favorites =
                            dataSnapshot.value as Map<dynamic, dynamic>?;

                        if (favorites == null || favorites.isEmpty) {
                          return const Center(
                              child: Text('You have no favorites.'));
                        }

                        var filteredFavorites =
                            favorites.entries.where((entry) {
                          String productName =
                              (entry.value['productName'] as String)
                                  .toLowerCase();
                          String category =
                              (entry.value['category'] as String).toLowerCase();
                          return productName.contains(_searchQuery) ||
                              category.contains(_searchQuery);
                        }).toList();

                        if (filteredFavorites.isEmpty) {
                          return const Center(
                              child: Text('No matching favorites found.'));
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
                          itemCount: filteredFavorites.length,
                          itemBuilder: (context, index) {
                            var favorite = filteredFavorites[index];
                            var productId = favorite.key;
                            var productData = favorite.value;

                            return ProductCard(
                              productId: productId,
                              category: productData['category'],
                              description: productData['description'],
                              imageUrl: productData['imageUrl'],
                              price: productData['price'],
                              productName: productData['productName'],
                              onAddToCart: () =>
                                  _addToCart(productId, productData),
                              onToggleFavorite: (isFavorite) => _toggleFavorite(
                                  productId, productData, isFavorite),
                              favoritesRef: _favoritesRef,
                              userId: _user!.uid,
                              onViewDetails: () =>
                                  _navigateToDetails(productId, productData),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text('No favorites found.'));
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
