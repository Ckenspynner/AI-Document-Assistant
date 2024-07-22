import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/document_provider.dart';
import '../../../utils/utils.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _documentNameController = TextEditingController(); // Controller for document name input

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);

    String title = 'Upload Document'; // Default title
    String doccontent = 'Browse and choose the files you want to upload.'; // Default doc content
    String background = 'assets/images/upload_illustration.png'; // Default background

    if (documentProvider.currentDocument != null) {
      title = 'Uploaded Document'; // Change title if document is uploaded
      background = 'assets/images/Uploaded.png'; // Upload background
      doccontent = 'Read Through'; // Default doc content
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: AppColors.primaryColor,
          expandedHeight: 400.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(title), // Dynamic title based on upload status
            background: Image.asset(
              background, // Ensure the image path is correct
              fit: BoxFit.cover, // Covers the app bar space
            ),
          ),
          actions: [
            if (documentProvider.isAuthenticated)
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor, // Set the background color
                  shape: BoxShape.circle, // Circular shape
                ),
                child: IconButton(
                  icon: Icon(Icons.person),
                  color: Colors.white, // Icon color
                  onPressed: () {
                    // Navigate to profile screen
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),
            SizedBox(width: 10,),
            if (documentProvider.isAuthenticated)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor, // Set the background color
                  shape: BoxShape.circle, // Circular shape
                ),
                child: IconButton(
                  icon: Icon(Icons.logout),
                  color: Colors.white, // Icon color
                  onPressed: () async {
                    await documentProvider.logout(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
            SizedBox(width: 10,),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  doccontent,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                if (documentProvider.isLoading)
                  CircularProgressIndicator() // Show loading indicator if uploading
                else if (documentProvider.currentDocument != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            documentProvider.originalContent.isNotEmpty
                                ? documentProvider.originalContent
                                : 'No content to display',
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 16.0,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Center-align the name of the uploaded file
                      Center(
                        child: Text(
                          'Document Name: ${documentProvider.currentDocument?.name ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                if (documentProvider.currentDocument == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 30, right: 30.0),
                    child: TextField(
                      controller: _documentNameController,
                      decoration: InputDecoration(
                        labelText: 'Give your file a name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0), // Adjust the value for the desired roundness
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0), // Left and right padding
                        suffixIcon: const Icon(Icons.description), // Trailing icon
                      ),
                      onChanged: (value) {
                        documentProvider.setDocumentName(value); // Update the document name
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _documentNameController.dispose(); // Dispose the controller to free up resources
    super.dispose();
  }
}
