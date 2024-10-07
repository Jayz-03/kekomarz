import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderID;

  const OrderStatusScreen({super.key, required this.orderID});

  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final DatabaseReference _ordersRef =
      FirebaseDatabase.instance.ref().child('Orders');
  User? _user;
  Map<String, dynamic>? _orderDetails;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    if (_user != null) {
      try {
        DataSnapshot snapshot =
            await _ordersRef.child(_user!.uid).child(widget.orderID).get();
        if (snapshot.exists) {
          setState(() {
            _orderDetails = Map<String, dynamic>.from(snapshot.value as Map);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching order details')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 164, 212),
        title: Text('Order Status', style: GoogleFonts.robotoCondensed()),
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
      body: _orderDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.shopping_bag),
                      title: Text(
                        'Order ID: ${widget.orderID}',
                        style: GoogleFonts.robotoCondensed(fontSize: 16),
                      ),
                      subtitle: Text(
                        'Order Status: ${_orderDetails!['orderStatus']}',
                        style: GoogleFonts.robotoCondensed(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(
                        'Receiver Name: ${_orderDetails!['receiverName']}',
                        style: GoogleFonts.robotoCondensed(fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address: ${_orderDetails!['address']}',
                            style: GoogleFonts.robotoCondensed(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mobile: ${_orderDetails!['mobileNumber']}',
                            style: GoogleFonts.robotoCondensed(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.price_check_outlined),
                      title: Text(
                        'Total Amount: ₱${_orderDetails!['totalAmount'].toStringAsFixed(2)}',
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Items:',
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _orderDetails!['items'].length,
                      itemBuilder: (context, index) {
                        final item = _orderDetails!['items'][index];
                        return Card(
                          elevation: 4,
                          color: Colors.white,
                          child: ListTile(
                            leading: Image.network(item['imageUrl']),
                            title: Text(
                              item['productName'],
                              style: GoogleFonts.robotoCondensed(fontSize: 16),
                            ),
                            subtitle: Text(
                              '₱${item['price']} x ${item['quantity']}',
                              style: GoogleFonts.robotoCondensed(fontSize: 14),
                            ),
                            trailing: Text(
                              '₱${(double.parse(item['price']) * item['quantity']).toStringAsFixed(2)}',
                              style: GoogleFonts.robotoCondensed(fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
