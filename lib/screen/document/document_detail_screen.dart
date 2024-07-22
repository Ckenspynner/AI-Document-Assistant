import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:document_assistant/provider/document_provider.dart';
import 'package:document_assistant/utils/utils.dart';
import 'dart:async';
import 'dart:io';

import '../../models/document.dart';

class DocumentDetailScreen extends StatefulWidget {
  final Document document;

  DocumentDetailScreen({required this.document});

  @override
  _DocumentDetailScreenState createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  double _progressValue = 0.0;
  String _progressText = "Processing document...";
  bool _isLoading = false;
  bool _suggestionRejected = false;
  bool _suggestionAccepted = false;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _showBottomSheet(); // Show bottom sheet when screen initializes
    _startProgress(); // Start progress timer
    _improveDocument(); // Start document improvement process
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progressValue < 0.9) {
          _progressValue += 0.05;
        } else {
          _progressTimer?.cancel();
        }
      });
    });
  }

  Future<void> _improveDocument() async {
    final documentProvider =
    Provider.of<DocumentProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _progressValue = 0.1;
    });

    await documentProvider.improveDocument(context, widget.document.id);

    setState(() {
      _progressValue = 1.0;
      _progressText = "Document processing complete!";
      _isLoading = false;
    });
  }

  Future<void> _downloadFile(String content, String extension) async {
    // Check and request storage permission
    if (await Permission.storage.request().isGranted) {
      // Get the external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Create the file with the specified extension
        final filePath = '${directory.path}/improved_document.$extension';
        final file = File(filePath);
        await file.writeAsString(content);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get external storage directory')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  void _showBottomSheet() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          final documentProvider =
          Provider.of<DocumentProvider>(context, listen: false);
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    const Text(
                      'Improved Document:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? Column(
                        children: [
                          SizedBox(height: 10),
                          Text(
                            "${(_progressValue * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          LinearProgressIndicator(
                              value: _progressValue,
                              color: AppColors.primaryColor),
                          SizedBox(height: 10),
                          Text(_progressText),
                        ],
                      )
                          : SingleChildScrollView(
                        child: Text(
                          documentProvider.improvedContent.isNotEmpty
                              ? documentProvider.improvedContent
                              : 'Improving content...',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14.0,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _suggestionRejected = true;
                              _suggestionAccepted = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryColor),
                          ),
                          child: const Text('Reject',
                              style: TextStyle(color: AppColors.primaryColor)),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _suggestionAccepted = true;
                              _suggestionRejected = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryColor),
                          ),
                          child: const Text('Accept',
                              style: TextStyle(color: AppColors.primaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel(); // Cancel the progress timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor, // Background color
      appBar: AppBar(
        title: const Text(
          'Document Detail',
          style: TextStyle(color: AppColors.scaffoldBackgroundColor),
        ),
        backgroundColor: AppColors.primaryColor, // AppBar color
        actions: _suggestionAccepted
            ? [
          PopupMenuButton<String>(
              onSelected: (value) {
                _downloadFile(documentProvider.improvedContent, value);
              },
              itemBuilder: (BuildContext context) {
                return {'txt', 'docx', 'pdf'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text('Download as .$choice'),
                  );
                }).toList();
              },
              icon: Container(
                padding: EdgeInsets.all(8.0), // Adjust padding as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // Color of the outline
                    width: 2.0, // Width of the outline
                  ),
                ),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                ),
              )),
        ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // For larger screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 20),
                          const Text(
                            'Original Document:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                documentProvider.originalContent.isNotEmpty
                                    ? documentProvider.originalContent
                                    : widget.document.originalContent,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          if (_suggestionRejected) const SizedBox(height: 20),
                          if (_suggestionRejected)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'You rejected the suggestion',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                            DocumentDetailScreen(
                                                document: widget.document),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                        Duration.zero,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: AppColors.primaryColor),
                                  ),
                                  child: Text(
                                    'Try Again',
                                    style: TextStyle(
                                        color: AppColors.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (_suggestionAccepted)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              'Improved Document:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  documentProvider.improvedContent.isNotEmpty
                                      ? documentProvider.improvedContent
                                      : 'Improving content...',
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              } else {
                // For smaller screens
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Original Document:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          documentProvider.originalContent.isNotEmpty
                              ? documentProvider.originalContent
                              : widget.document.originalContent,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14.0,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_suggestionAccepted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Improved Document:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                documentProvider.improvedContent.isNotEmpty
                                    ? documentProvider.improvedContent
                                    : 'Improving content...',
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (_suggestionRejected)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'You rejected the suggestion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                      DocumentDetailScreen(
                                          document: widget.document),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primaryColor),
                            ),
                            child: const Text(
                              'Try Again',
                              style: TextStyle(color: AppColors.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
