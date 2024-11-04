import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  late Size mediaSize;

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 200, 164, 212),
          title: Text('About Us', style: GoogleFonts.robotoCondensed()),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Image.asset(
                          'assets/images/kekomarz-logo.png',
                          width: 120,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Divider(),
                  SizedBox(height: 16.0),
                  Text(
                    textAlign: TextAlign.justify,
                    'Welcome to Kekomarz Motor Shop, your trusted partner for top-quality motorcycle parts and services. Established with a commitment to excellence and a passion for motorcycles, Kekomarz has grown into a hub for enthusiasts who seek reliability, performance, and exceptional service. \n\nWe offer a wide selection of premium parts and accessories, from OEM components to custom upgrades, catering to all major makes and models. Our team of experienced mechanics and technicians are equipped to handle everything from routine maintenance and repairs to advanced performance enhancements, ensuring your motorcycle receives the highest level of care.\n\nAt Kekomarz, we value innovation and customer satisfaction. Our new mobile app allows you to conveniently manage your orders, track deliveries in real-time, and even visualize custom designs for your motorcycle. With streamlined ordering and secure payment options, we are dedicated to providing a seamless and enjoyable experience, both online and in-store.\n\nThank you for choosing Kekomarz Motor Shop. We look forward to being part of your journey on the road!',
                    style: GoogleFonts.robotoCondensed(),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
