import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kekomarz/screens/auth/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController municipalityController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Utility to create TextFormField widgets
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: isPassword || isConfirmPassword ? !_isPasswordVisible : false,
        cursorColor: Colors.white,
        style: GoogleFonts.robotoCondensed(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: isPassword || isConfirmPassword
              ? IconButton(
                  icon: Icon(
                    isPassword
                        ? (_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off)
                        : (_isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _isPasswordVisible = !_isPasswordVisible;
                      } else {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      }
                    });
                  },
                )
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.robotoCondensed(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final user = userCredential.user;
      final userId = user?.uid;

      // Merge address fields into a complete address
      String completeAddress = '${streetController.text}, ${barangayController.text}, ${municipalityController.text}';

      if (user != null) {
        await user.sendEmailVerification();
        await _database.child('users/$userId').set({
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "email": emailController.text,
          "address": completeAddress,  // Store the complete address
          "mobileNumber": mobileNumberController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Please verify your email.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 200, 164, 212),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset('assets/images/kekomarz-logo.png', height: 120),
                ),
                Text(
                  'Sign up to continue!',
                  style: GoogleFonts.robotoCondensed(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                // Use the utility method to create text fields
                _buildTextField(
                  controller: firstNameController,
                  hint: 'First Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'First name is required';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: lastNameController,
                  hint: 'Last Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Last name is required';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: emailController,
                  hint: 'Email address',
                  icon: Icons.mail,
                  inputType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter a valid email address';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: streetController,
                  hint: 'Street',
                  icon: Icons.streetview,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Street is required';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: barangayController,
                  hint: 'Barangay',
                  icon: Icons.location_city,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Barangay is required';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: municipalityController,
                  hint: 'Municipality',
                  icon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Municipality is required';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: mobileNumberController,
                  hint: 'Mobile Number',
                  icon: Icons.call,
                  inputType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Mobile number is required';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Enter a valid mobile number';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: passwordController,
                  hint: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 8 || !RegExp(r'[A-Z]').hasMatch(value) || !RegExp(r'[a-z]').hasMatch(value) ||
                        !RegExp(r'[0-9]').hasMatch(value) || !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock,
                  isConfirmPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: GoogleFonts.robotoCondensed(fontSize: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: GoogleFonts.robotoCondensed(fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                      child: Text('Login', style: GoogleFonts.robotoCondensed(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
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
