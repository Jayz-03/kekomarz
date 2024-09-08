import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekomarz/screens/cart/order-status.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.selectedProducts,
    required this.totalAmount,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  User? _user;
  Map<String, dynamic>? _userDetails;
  final double _shippingFee = 60.00;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (_user != null) {
      try {
        DataSnapshot snapshot = await _usersRef.child(_user!.uid).get();
        if (snapshot.exists) {
          setState(() {
            _userDetails = Map<String, dynamic>.from(snapshot.value as Map);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching user details')),
        );
      }
    }
  }

  void _placeOrder() async {
    if (_user == null || _userDetails == null) return;

    try {
      // Prepare the order data
      final orderData = {
        'totalAmount': widget.totalAmount + _shippingFee,
        'orderStatus': 'Pending',
        'receiverName':
            '${_userDetails!['firstName']} ${_userDetails!['lastName']}',
        'address': _userDetails!['address'],
        'mobileNumber': _userDetails!['mobileNumber'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'items': widget.selectedProducts,
      };

      // Push the order to Firebase and get the orderID (key)
      final DatabaseReference ordersRef =
          FirebaseDatabase.instance.ref().child('Orders').child(_user!.uid);
      final orderRef = ordersRef.push();
      await orderRef.set(orderData);

      final String orderID = orderRef.key!; // Get the generated orderID

      print("Order successfully placed with orderID: $orderID.");

      // Remove the ordered items from the user's cart
      final DatabaseReference cartsRef =
          FirebaseDatabase.instance.ref().child('Carts').child(_user!.uid);

      bool allRemoved = true;
      for (var product in widget.selectedProducts) {
        String? productId = product['productId'] as String?;
        if (productId != null) {
          await cartsRef.child(productId).remove().catchError((error) {
            allRemoved = false;
            print(
                "Failed to remove product from cart: $productId - Error: $error");
          });
        } else {
          allRemoved = false;
          print(
              "Error: Product ID is null for product ${product['productName']}");
        }
      }

      if (allRemoved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order placed successfully! Cart updated.')),
        );

        // Navigate to OrderStatusScreen with the orderID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderStatusScreen(orderID: orderID),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order placed, but failed to update cart.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error placing the order')),
      );
      print("Error placing order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalWithShipping = widget.totalAmount + _shippingFee;

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
      body: _userDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(Icons.location_on,
                                  size: 60,
                                  color: Color.fromARGB(255, 59, 27, 13)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_userDetails!['firstName']} ${_userDetails!['lastName']}',
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 59, 27, 13)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_userDetails!['address']}',
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 59, 27, 13)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_userDetails!['mobileNumber']}',
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 59, 27, 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = widget.selectedProducts[index];
                        return ListTile(
                          leading: Image.network(
                            product['imageUrl'],
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            product['productName'],
                            style: GoogleFonts.robotoCondensed(
                                fontSize: 16,
                                color: Color.fromARGB(255, 59, 27, 13),
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '₱${product['price']} x ${product['quantity']}',
                            style: GoogleFonts.robotoCondensed(
                                fontSize: 14,
                                color: Color.fromARGB(255, 59, 27, 13)),
                          ),
                          trailing: Text(
                            '₱${(double.parse(product['price']) * product['quantity']).toStringAsFixed(2)}',
                            style: GoogleFonts.robotoCondensed(
                                fontSize: 14,
                                color: Color.fromARGB(255, 59, 27, 13)),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Subtotal: ₱${widget.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Shipping Fee: ₱$_shippingFee',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Total Amount: ₱${totalWithShipping.toStringAsFixed(2)}',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      child: Text(
                        'Place Order',
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 200, 164, 212),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
