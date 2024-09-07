import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseReference _cartsRef =
      FirebaseDatabase.instance.ref().child('Carts');
  User? _user;
  Map<String, dynamic> _cartItems = {};
  double _totalAmount = 0.0;
  Map<String, bool> _selectedItems = {}; // Track selected items

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    if (_user != null) {
      try {
        DataSnapshot snapshot = await _cartsRef.child(_user!.uid).get();
        if (snapshot.exists) {
          setState(() {
            _cartItems = Map<String, dynamic>.from(snapshot.value as Map);
            _selectedItems = Map.fromIterable(
              _cartItems.keys,
              key: (key) => key,
              value: (key) => false,
            );
            _calculateTotalAmount();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching cart items')),
        );
      }
    }
  }

  void _calculateTotalAmount() {
    _totalAmount = _cartItems.entries
        .where((entry) => _selectedItems[entry.key] == true)
        .fold(0.0, (sum, entry) {
      final product = entry.value;
      double price = double.parse(product['price']);
      int quantity = product['quantity'];
      return sum + (price * quantity);
    });
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    if (_user != null) {
      try {
        if (newQuantity <= 0) {
          // Remove item if quantity is zero or less
          await _cartsRef.child(_user!.uid).child(productId).remove();
          setState(() {
            _cartItems.remove(productId);
            _selectedItems.remove(productId);
            _calculateTotalAmount();
          });
        } else {
          await _cartsRef
              .child(_user!.uid)
              .child(productId)
              .update({'quantity': newQuantity});
          setState(() {
            _fetchCartItems();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating quantity')),
        );
      }
    }
  }

  void _onItemSelected(String productId, bool? isSelected) {
    setState(() {
      _selectedItems[productId] = isSelected ?? false;
      _calculateTotalAmount();
    });
  }

  void _checkout() {
    // Handle the checkout process
    // This can involve navigating to a checkout page, or other actions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to checkout...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cartItems.isEmpty
          ? Center(
              child: Text('Your cart is empty.',
                  style: GoogleFonts.robotoCondensed(fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _cartItems.entries.map((entry) {
                        String productId = entry.key;
                        Map<String, dynamic> product =
                            Map<String, dynamic>.from(entry.value);

                        return Card(
                          elevation: 4.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _selectedItems[productId] ??
                                      false, // Ensure non-null value
                                  onChanged: (bool? isSelected) {
                                    _onItemSelected(productId, isSelected);
                                  },
                                ),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Image.network(
                                      product['imageUrl'],
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(product['productName'],
                                        style: GoogleFonts.robotoCondensed(
                                            fontSize: 16)),
                                    subtitle: Text('₱${product['price']}',
                                        style: GoogleFonts.robotoCondensed(
                                            fontSize: 14)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            int currentQuantity =
                                                product['quantity'];
                                            if (currentQuantity > 1) {
                                              _updateQuantity(productId,
                                                  currentQuantity - 1);
                                            } else if (currentQuantity == 1) {
                                              // If quantity is 1, remove item from cart
                                              _updateQuantity(productId, 0);
                                            }
                                          },
                                        ),
                                        Text('${product['quantity']}',
                                            style: GoogleFonts.robotoCondensed(
                                                fontSize: 16)),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            int currentQuantity =
                                                product['quantity'];
                                            _updateQuantity(
                                                productId, currentQuantity + 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Total Amount: ₱${_totalAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _checkout,
                        child: Text(
                          'Checkout',
                          style: GoogleFonts.robotoCondensed(
                              fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 200, 164, 212),
                          textStyle: GoogleFonts.robotoCondensed(
                              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
