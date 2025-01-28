import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sign Up",
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AnimatedOpacity(
        duration: const Duration(seconds: 1),
        opacity: 1.0,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3A1C71), // Purple
                Color(0xFFD76D77), // Pink
                Color(0xFFFFAF7B)  // Peach
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SignUp Heading
                    FadeInUp(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        "Create a New Account",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form for Sign Up
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username Input Field
                          TextFormField(
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              hintText: "Enter your username",
                              hintStyle: const TextStyle(color: Colors.black54),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email Input Field
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              String pattern =
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              hintText: "Enter your email",
                              hintStyle: const TextStyle(color: Colors.black54),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password Input Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              hintText: "Enter your password",
                              hintStyle: const TextStyle(color: Colors.black54),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Sign Up Button
                          FadeInUp(
                            duration: const Duration(seconds: 1),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Proceed with Sign Up logic
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Processing Sign Up')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                elevation: 5,
                              ),
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Sign In Redirection Text
                          FadeInUp(
                            duration: const Duration(seconds: 1),
                            child: TextButton(
                              onPressed: () {
                                // Navigate to Sign In
                                Navigator.pushNamed(context, '/signin');
                              },
                              child: Text(
                                "Already have an account? Sign In",
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
