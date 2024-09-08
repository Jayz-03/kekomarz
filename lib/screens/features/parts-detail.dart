import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PartsDetailScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String category;
  final String description;
  final String imageUrl;
  final String price;

  const PartsDetailScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  @override
  _PartsDetailScreenState createState() => _PartsDetailScreenState();
}

class _PartsDetailScreenState extends State<PartsDetailScreen> {
  final DatabaseReference _cartsRef = FirebaseDatabase.instance.ref().child('Carts');
  final DatabaseReference _favoritesRef = FirebaseDatabase.instance.ref().child('Favorites');
  User? _user;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    if (_user != null) {
      DatabaseReference favoriteRef = _favoritesRef.child(_user!.uid).child(widget.productId);
      DataSnapshot snapshot = await favoriteRef.get();
      setState(() {
        _isFavorite = snapshot.exists;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_user != null) {
      try {
        DatabaseReference cartRef = _cartsRef.child(_user!.uid).child(widget.productId);
        DataSnapshot snapshot = await cartRef.get();

        if (snapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product is already in the cart!')),
          );
        } else {
          Map<String, dynamic> productMap = {
            'productName': widget.productName,
            'category': widget.category,
            'description': widget.description,
            'imageUrl': widget.imageUrl,
            'price': widget.price,
            'quantity': 1,
          };
          await cartRef.set(productMap);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to Cart!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding to cart')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_user != null) {
      if (_isFavorite) {
        await _favoritesRef.child(_user!.uid).child(widget.productId).remove();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from Favorites!')),
        );
      } else {
        Map<String, dynamic> productMap = {
          'productName': widget.productName,
          'category': widget.category,
          'description': widget.description,
          'imageUrl': widget.imageUrl,
          'price': widget.price,
        };
        await _favoritesRef.child(_user!.uid).child(widget.productId).set(productMap);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Favorites!')),
        );
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.grey,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                  Positioned.fill(
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.grey,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.productName,
              style: GoogleFonts.robotoCondensed(
                color: const Color.fromARGB(255, 59, 27, 13),
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₱${widget.price}',
              style: GoogleFonts.robotoCondensed(
                color: const Color.fromARGB(255, 59, 27, 13),
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: GoogleFonts.robotoCondensed(
                color: const Color.fromARGB(255, 59, 27, 13),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.green,),
                  color: const Color.fromARGB(255, 100, 59, 159),
                  onPressed: _addToCart,
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
