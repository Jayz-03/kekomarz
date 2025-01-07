import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  List<String?> selectedServices = [null];
  List<double> servicePrices = [0.0];
  List<TextEditingController> serviceNotesControllers = [
    TextEditingController()
  ];

  String? selectedBrand;
  final List<String> motorcycleBrands = [
    "Honda",
    "Yamaha",
    "Kawasaki",
    "Suzuki",
    "Big Bike"
  ];

  final TextEditingController vehicleModelController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  File? _image;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Map<String, double> services = {
    "Oil and Filter Change": 500.0,
    "Tire Replacement": 1000.0,
    "Brake Adjustment": 300.0,
    "Chain and Sprocket Replacement": 1200.0,
    "Tune-Up": 600.0,
    "Carburetor Cleaning": 700.0,
    "Clutch Replacement": 800.0,
    "Electrical System Repair": 1500.0,
    "Engine Overhaul": 5000.0,
    "Suspension Repair": 2000.0,
    "General Wash": 250.0,
    "Battery Charging": 150.0,
  };

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

// Upload image to Firebase Storage and get the download URL
  Future<String?> _uploadImage(File image, String userId) async {
    try {
      String fileName =
          "service_images/${DateTime.now().millisecondsSinceEpoch}_$userId.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload error: $e");
      return null; // Return null if upload fails
    }
  }

  Future<void> _submitService() async {
    if (!_validateForm()) return; // Validate before proceeding
    setState(() {
      _isLoading = true; // Start loading
    });

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false; // Stop loading if user is not logged in
      });
      return;
    }

    String userId = user.uid;
    DatabaseReference serviceRef =
        FirebaseDatabase.instance.ref("Services/$userId").push();

    // Upload image if selected
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadImage(
          _image!, userId); // Upload the image to Firebase Storage
    }

    List<Map<String, dynamic>> servicesData = [];
    for (int i = 0; i < selectedServices.length; i++) {
      if (selectedServices[i] != null) {
        servicesData.add({
          "service": selectedServices[i],
          "price": servicePrices[i],
          "note": serviceNotesControllers[i].text,
        });
      }
    }

    Map<String, dynamic> serviceData = {
      "services": servicesData,
      "vehicleModel": vehicleModelController.text,
      "totalFee": servicePrices.reduce((a, b) => a + b),
      "imageUrl": imageUrl ?? "No Image", // Store the image URL
      "serviceStatus": "Pending",
      "timestamp": DateTime.now().toIso8601String(),
    };

    await serviceRef.set(serviceData);

    setState(() {
      selectedServices = [null];
      servicePrices = [0.0];
      serviceNotesControllers = [TextEditingController()];
      vehicleModelController.clear();
      _image = null;
      _isLoading = false; // Stop loading
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service appointment scheduled successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _calculateTotalFee() {
    setState(() {
      double total = servicePrices.reduce((a, b) => a + b);
      // Apply 10% increase if 'Big Bike' is selected
      if (selectedBrand == "Big Bike") {
        total *= 1.10; // Increase price by 10%
      }
      servicePrices = [total];
    });
  }

  void _addServiceDropdown() {
    setState(() {
      selectedServices.add(null);
      servicePrices.add(0.0);
      serviceNotesControllers.add(TextEditingController());
    });
  }

  bool _validateForm() {
    if (selectedServices.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (vehicleModelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the vehicle model.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    double totalServiceFee = servicePrices.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 164, 212),
        title: Text('Service', style: GoogleFonts.robotoCondensed()),
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
          ? Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 100, 59, 159)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customize",
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickImage,
                        child: _image != null
                            ? Image.file(_image!, height: 150)
                            : Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Center(
                                  child: Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedBrand,
                        hint: Text("Select Motorcycle Brand",
                            style: GoogleFonts.robotoCondensed()),
                        items: motorcycleBrands.map((String brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand,
                                style: GoogleFonts.robotoCondensed()),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedBrand = newValue;
                          });
                          _calculateTotalFee(); // Recalculate price if brand changes
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Estimated Price: ₱${totalServiceFee.toStringAsFixed(2)}",
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Repair / Maintenance",
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children:
                            List.generate(selectedServices.length, (index) {
                          return Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedServices[index],
                                hint: Text("Select a Service",
                                    style: GoogleFonts.robotoCondensed()),
                                items: services.keys.map((String service) {
                                  return DropdownMenuItem<String>(
                                    value: service,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(service,
                                            style:
                                                GoogleFonts.robotoCondensed()),
                                        Text(
                                            "₱${services[service]!.toStringAsFixed(2)}",
                                            style:
                                                GoogleFonts.robotoCondensed()),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedServices[index] = newValue;

                                    if (newValue != null) {
                                      servicePrices[index] =
                                          services[newValue]!;
                                    } else {
                                      servicePrices[index] = 0.0;
                                    }
                                    _calculateTotalFee();
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                style: GoogleFonts.robotoCondensed(),
                                controller: serviceNotesControllers[index],
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.note),
                                  hintText: "Leave a note for this service",
                                  hintStyle: GoogleFonts.robotoCondensed(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 100, 59, 159),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 100, 59, 159),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 100, 59, 159),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _addServiceDropdown,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 200, 164, 212),
                          textStyle: GoogleFonts.robotoCondensed(
                              fontSize: 16, color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        label: Text("Add more service",
                            style: GoogleFonts.robotoCondensed(
                                color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                      Divider(),
                      const SizedBox(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Total Payment: ₱${totalServiceFee.toStringAsFixed(2)}",
                            style: GoogleFonts.robotoCondensed(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_validateForm()) {
                                _submitService();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 100, 59, 159),
                              textStyle: GoogleFonts.robotoCondensed(
                                  fontSize: 16, color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Schedule Appointment",
                                style: GoogleFonts.robotoCondensed(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
