import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatefulWidget {
  final String productId;
  final String category;
  final String description;
  final String imageUrl;
  final String price;
  final String productName;
  final int stock; // Add stock property
  final VoidCallback onAddToCart;
  final Function(bool isFavorite) onToggleFavorite;
  final DatabaseReference favoritesRef;
  final String userId;
  final VoidCallback onViewDetails;

  const ProductCard({
    super.key,
    required this.productId,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.productName,
    required this.stock, // Include stock here
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.favoritesRef,
    required this.userId,
    required this.onViewDetails,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      DatabaseReference favoriteRef =
          widget.favoritesRef.child(widget.userId).child(widget.productId);
      DataSnapshot snapshot = await favoriteRef.get();
      if (mounted) {
        setState(() {
          _isFavorite = snapshot.exists;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error checking favorite status')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await widget.favoritesRef
            .child(widget.userId)
            .child(widget.productId)
            .remove();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from Favorites!')),
          );
        }
      } else {
        Map<String, dynamic> productMap = {
          'category': widget.category,
          'description': widget.description,
          'imageUrl': widget.imageUrl,
          'price': widget.price,
          'productName': widget.productName,
          'quantity': 1,
        };
        await widget.favoritesRef
            .child(widget.userId)
            .child(widget.productId)
            .set(productMap);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to Favorites!')),
          );
        }
      }
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating favorite status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onViewDetails,
      child: Card(
        color: const Color.fromARGB(255, 241, 240, 240),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.productName,
                style: GoogleFonts.robotoCondensed(
                  color: const Color.fromARGB(255, 59, 27, 13),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '₱${widget.price}',
                style: GoogleFonts.robotoCondensed(
                    color: const Color.fromARGB(255, 59, 27, 13), fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Stock: ${widget.stock}', // Display stock
                style: GoogleFonts.robotoCondensed(
                    color: const Color.fromARGB(255, 59, 27, 13), fontSize: 12),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.green,
                  ),
                  onPressed: widget.onAddToCart,
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => widget.onToggleFavorite(_isFavorite),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
