import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/document_provider.dart';
import 'document_detail_screen.dart';

class DocumentHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the document provider
    final documentProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Document History'), // Title of the app bar
      ),
      body: ListView.builder(
        // Build a list of documents
        itemCount: documentProvider.documents.length, // Number of documents
        itemBuilder: (context, index) {
          final document = documentProvider.documents[index]; // Access each document
          return ListTile(
            title: Text('Document ${document.id}'), // Display document ID
            subtitle: Text('Status: ${document.status}'), // Display document status
            onTap: () {
              // Navigate to DocumentDetailScreen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentDetailScreen(document: document),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
