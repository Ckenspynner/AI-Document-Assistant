import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/document_provider.dart';
import 'document_detail_screen.dart';
import '../../utils/utils.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  _DocumentListScreenState createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  late Future<void> _fetchDocumentsFuture;

  @override
  void initState() {
    super.initState();
    _fetchDocumentsFuture = _fetchDocuments(); // Fetch documents on init
  }

  Future<void> _fetchDocuments() async {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    await documentProvider.fetchDocumentHistory(context); // Fetch document history
  }

  void refreshPage() {
    setState(() {
      _fetchDocumentsFuture = _fetchDocuments(); // Refresh the documents list
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor, // Background color
      body: FutureBuilder<void>(
        future: _fetchDocumentsFuture, // Future for fetching documents
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while fetching documents
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if fetching fails
            return Center(child: Text('Error fetching documents'));
          } else {
            return CustomScrollView(
              slivers: <Widget>[
                const SliverAppBar(
                  title: Text('Uploaded Documents', style: TextStyle(color: AppColors.scaffoldBackgroundColor)),
                  pinned: true,
                  backgroundColor: AppColors.primaryColor,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final document = documentProvider.documents[index];
                      return Column(
                        children: [
                          Dismissible(
                            key: Key(document.id.toString()), // Unique key for each document
                            onDismissed: (direction) async {
                              // Handle document dismissal (delete)
                              await documentProvider.deleteDocument(context, document.id);
                              setState(() {
                                documentProvider.documents.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${document.name} dismissed')),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.delete, color: Colors.white), // Delete icon
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primaryColor,
                                child: Icon(Icons.upload_file, color: Colors.white), // File icon
                              ),
                              title: Text(document.name), // Document name
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${document.status}'), // Document status
                                  Text('Uploaded: ${document.uploadDate.substring(0, 10)}'), // Upload date
                                ],
                              ),
                              onTap: () {
                                // Navigate to DocumentDetailScreen on tap
                                documentProvider.fetchDocumentContent(context, document.id).then((_) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DocumentDetailScreen(document: document),
                                    ),
                                  );
                                });
                              },
                              trailing: Icon(Icons.more_vert), // More options icon
                            ),
                          ),
                          const Divider(indent: 20, endIndent: 20), // Divider between items
                        ],
                      );
                    },
                    childCount: documentProvider.documents.length, // Number of documents
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
