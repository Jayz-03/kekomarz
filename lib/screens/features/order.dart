import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekomarz/screens/cart/order-status.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final DatabaseReference _ordersRef =
      FirebaseDatabase.instance.ref().child('Orders');
  User? _user;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserOrders();
  }

  Future<void> _fetchUserOrders() async {
    if (_user != null) {
      try {
        DataSnapshot snapshot = await _ordersRef.child(_user!.uid).get();
        if (snapshot.exists) {
          setState(() {
            _orders = (snapshot.value as Map).entries.map((entry) {
              Map<String, dynamic> order = Map<String, dynamic>.from(entry.value);
              order['orderID'] = entry.key;  // Add the orderID to the order data
              return order;
            }).toList();
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching orders')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders', style: GoogleFonts.robotoCondensed()),
      ),
      body: _orders.isEmpty
          ? const Center(child: Text('You have no orders yet.'))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return ListTile(
                  title: Text(
                    'Order ID: ${order['orderID']}',
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Total: ₱${order['totalAmount'].toStringAsFixed(2)}',
                    style: GoogleFonts.robotoCondensed(fontSize: 14),
                  ),
                  trailing: Text(
                    order['orderStatus'],
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 14, color: Colors.green),
                  ),
                  onTap: () {
                    // Navigate to OrderStatusScreen with orderID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderStatusScreen(orderID: order['orderID']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
