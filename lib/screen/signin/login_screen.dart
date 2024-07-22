import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:document_assistant/provider/document_provider.dart';
import 'package:document_assistant/screen/document/documentscreen.dart';
import '../../utils/constants.dart';
import '../../utils/utils.dart';

class LoginScreen extends StatelessWidget {
  // Controllers for the email and password text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Global key to validate the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Accessing the DocumentProvider
    final documentProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor, // Set background color
      body: Stack(
        children: <Widget>[
          // Light blue shapes in the background
          Positioned(
            top: -140,
            right: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Top blue shape
          Positioned(
            top: -140,
            right: -70,
            child: Container(
              width: 270,
              height: 270,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom light blue shapes
          Positioned(
            bottom: -240,
            left: 10,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom blue shape
          Positioned(
            bottom: -230,
            left: 0,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Form for login
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                        top: 25.0, left: 25, right: 25, bottom: 50),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50),
                        // Email text field
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 50),
                        // Password text field
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 50),
                        // Sign in button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: AppColors.primaryColor,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final url = Uri.parse(loginUrl);
                                final response = await http.post(
                                  url,
                                  body: json.encode({
                                    'username': emailController.text,
                                    'password': passwordController.text,
                                  }),
                                  headers: {'Content-Type': 'application/json'},
                                );

                                if (response.statusCode == 200) {
                                  var data = json.decode(response.body);
                                  String token = data['token'];
                                  await documentProvider.updateToken(token); // Ensure updateToken is awaited
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DocumentScreen()),
                                  );
                                } else {
                                  var errorData = json.decode(response.body);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Login failed: ${errorData['error']}')),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'SIGN IN',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Forgot password button
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Sign up button
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register'); // Navigate to the signup page
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "don't have an account? ",
                              style: TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: 'SIGN UP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
