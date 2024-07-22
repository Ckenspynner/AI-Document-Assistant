import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:document_assistant/provider/document_provider.dart';

import '../../utils/utils.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false; // To track if the profile is in editing mode
  late Map<String, dynamic> _originalUserData; // To store the original user data

  @override
  void initState() {
    super.initState();
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    _fetchUserData(documentProvider); // Fetch user data on initialization
  }

  Future<void> _fetchUserData(DocumentProvider documentProvider) async {
    await documentProvider.fetchUserData(); // Fetch user data from the provider
    _originalUserData = Map.from(documentProvider.userData); // Make a copy of the original data
    _populateUserData(documentProvider); // Populate text fields with user data
  }

  void _populateUserData(DocumentProvider documentProvider) {
    _usernameController.text = documentProvider.userData['username'] ?? '';
    _firstNameController.text = documentProvider.userData['first_name'] ?? '';
    _lastNameController.text = documentProvider.userData['last_name'] ?? '';
    _emailController.text = documentProvider.userData['email'] ?? '';
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing; // Toggle editing mode
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false; // Cancel editing mode
      _populateUserData(Provider.of<DocumentProvider>(context, listen: false)); // Reset text fields to original data
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Light background color
      body: SafeArea(
        child: Column(
          children: [
            // Top profile section
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor, // Light purple background color
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context); // Go back to the previous screen
                        },
                      ),
                      Icon(Icons.more_vert, color: Colors.black),
                    ],
                  ),
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/upload_illustration.png'), // Your profile picture
                  ),
                  SizedBox(height: 10),
                  Text(
                    documentProvider.userData['username'] ?? '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_isEditing) {
                        Map<String, dynamic> updatedData = {
                          'username': _usernameController.text,
                          'first_name': _firstNameController.text,
                          'last_name': _lastNameController.text,
                          'email': _emailController.text,
                        };
                        documentProvider.updateUserData(context, updatedData); // Update user data if editing
                      }
                      _toggleEditing(); // Toggle editing mode
                    },
                    child: Text(_isEditing ? 'Save Changes' : 'Edit Profile'),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Menu options
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: Color(0xFFFFC107)),
                      title: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(labelText: 'First Name'),
                        readOnly: !_isEditing,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      leading: Icon(Icons.person, color: Color(0xFF4CAF50)),
                      title: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(labelText: 'Last Name'),
                        readOnly: !_isEditing,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: Color(0xFFF44336)),
                      title: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        readOnly: !_isEditing,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                    ListTile(
                      leading: Icon(Icons.person, color: Color(0xFF3B3F51)),
                      title: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                        readOnly: !_isEditing,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isEditing)
                  Container(
                    margin: EdgeInsets.all(8.0), // Add margin to the button
                    child: ElevatedButton(
                      onPressed: _cancelEditing, // Cancel editing
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red color for the cancel button
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0), // Add padding to the text
                        child: Text('Cancel'),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
