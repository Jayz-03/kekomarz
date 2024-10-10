import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceProgressScreen extends StatefulWidget {
  const ServiceProgressScreen({Key? key}) : super(key: key);

  @override
  _ServiceProgressScreenState createState() => _ServiceProgressScreenState();
}

class _ServiceProgressScreenState extends State<ServiceProgressScreen> {
  final DatabaseReference _serviceRef =
      FirebaseDatabase.instance.ref("Services");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _servicesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  Future<void> _fetchServiceData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      DatabaseReference userServicesRef = _serviceRef.child(userId);
      userServicesRef.once().then((DatabaseEvent event) {
        Map<dynamic, dynamic>? servicesData = event.snapshot.value as Map?;
        if (servicesData != null) {
          servicesData.forEach((key, value) {
            setState(() {
              _servicesList.add({
                "vehicleModel": value["vehicleModel"],
                "totalFee": value["totalFee"],
                "serviceStatus": value["serviceStatus"],
                "imageUrl": value["imageUrl"],
              });
            });
          });
        }
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 164, 212),
        title: Text('Service Progress', style: GoogleFonts.robotoCondensed()),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servicesList.isEmpty
              ? const Center(child: Text("No service records found."))
              : ListView.builder(
                  itemCount: _servicesList.length,
                  itemBuilder: (context, index) {
                    final service = _servicesList[index];
                    return Card(
                      elevation: 4,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (service['imageUrl'] != null)
                              Image.network(
                                service['imageUrl'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(height: 10),
                            Text(
                              'Vehicle Model: ${service['vehicleModel'] ?? "N/A"}',
                              style: GoogleFonts.robotoCondensed(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Total Fee: ₱${service['totalFee']?.toStringAsFixed(2) ?? "0.00"}',
                              style: GoogleFonts.robotoCondensed(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Service Status: ${service['serviceStatus'] ?? "Pending"}',
                              style: GoogleFonts.robotoCondensed(
                                fontSize: 16,
                                color: service['serviceStatus'] == "Pending"
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
