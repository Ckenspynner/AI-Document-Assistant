import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:document_assistant/provider/document_provider.dart';

import '../../utils/bottomnav.dart';
import '../../utils/utils.dart';
import 'document_list_screen.dart';
import 'home/body.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  int _selectedIndex = 0; // Index for the selected bottom navigation item
  Key _documentListKey = UniqueKey(); // Unique key for the document list

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        _documentListKey = UniqueKey(); // Refresh the document list on tap
      }
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor, // Background color
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex, // Show the selected screen
        children: <Widget>[
          const Center(child: Homepage()), // Homepage widget
          Center(child: DocumentListScreen(key: _documentListKey)), // Document list screen
        ],
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(20), // Padding around the floating action button
        child: FloatingActionButton(
          onPressed: documentProvider.isUploaded
              ? () => documentProvider.clearCurrentDocument() // Clear document if uploaded
              : () => documentProvider.uploadDocument(context), // Upload document if not uploaded
          backgroundColor: AppColors.primaryColor,
          tooltip: 'Upload File',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
          ),
          child: Icon(
            documentProvider.isUploaded ? Icons.refresh : Icons.upload_file, // Icon based on upload status
            color: AppColors.scaffoldBackgroundColor,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Position of the floating action button
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex, // Selected index for the bottom navigation bar
        onItemTapped: _onItemTapped, // Function to handle item tap
      ),
    );
  }
}
