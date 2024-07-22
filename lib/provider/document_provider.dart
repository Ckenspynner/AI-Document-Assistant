import 'package:document_assistant/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DocumentProvider with ChangeNotifier {
  Document? _currentDocument;
  bool _isLoading = false;
  List<Document> _documents = [];
  bool _isAuthenticated = false;
  bool _isUploaded = false;
  String? _documentName;

  Document? get currentDocument => _currentDocument;
  bool get isLoading => _isLoading;
  List<Document> get documents => _documents;
  bool get isAuthenticated => _isAuthenticated;
  bool get isUploaded => _isUploaded;

  String get originalContent => _currentDocument?.originalContent ?? '';
  String get improvedContent => _currentDocument?.improvedContent ?? '';
  String? get documentName => _documentName;

  String? _token;
  final _storage = const FlutterSecureStorage();  // Secure storage instance

  // User data
  Map<String, dynamic> _userData = {};

  Map<String, dynamic> get userData => _userData;

  // Update the token and store it in secure storage
  Future<void> updateToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);  // Store the token
    _isAuthenticated = true;
    await fetchUserData();
    notifyListeners();
  }

  // Fetch user data
  Future<void> fetchUserData() async {
    final url = Uri.parse(userUrl);  // Replace with your API endpoint for user data
    if (_token == null) return;

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $_token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      _userData = json.decode(response.body);
      notifyListeners();
    }
  }

  // Update user data
  Future<void> updateUserData(BuildContext context, Map<String, dynamic> updatedData) async {
    final url = Uri.parse(userUrl);  // Replace with your API endpoint for user data
    if (_token == null) return;

    final response = await http.put(
      url,
      body: json.encode(updatedData),
      headers: {
        'Authorization': 'Token $_token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      _userData = json.decode(response.body);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User data updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user data')),
      );
    }
  }

  // Check and load token from secure storage
  Future<void> checkAndLoadToken() async {
    try {
      _token = await _storage.read(key: 'token');  // Read the token
      _isAuthenticated = _token != null;
    } catch (e) {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  // Clear the token and navigate to the login screen
  Future<void> logout(BuildContext context) async {
    _token = null;
    await _storage.delete(key: 'token');  // Delete the token from storage
    _isAuthenticated = false;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/login');  // Navigate to the login screen
  }

  // Handle document upload
  Future<void> uploadDocument(BuildContext context) async {
    if (_documentName == null || _documentName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a document name')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'docx', 'pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      _isLoading = true;
      notifyListeners();

      final url = Uri.parse(uploadsUrl);

      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
      request.fields['name'] = _documentName!;

      if (_token != null) {
        request.headers['Authorization'] = 'Token $_token';
      }

      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          var responseData = await response.stream.bytesToString();
          var data = json.decode(responseData);
          _currentDocument = Document.fromJson(data);
          _isUploaded = true; // Mark as uploaded
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document uploaded successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload document')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload document')),
        );
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No document selected')),
      );
    }
  }

  Future<void> deleteDocument(BuildContext context, int documentId) async {
    final url = Uri.parse('$documentsUrl/$documentId/delete/');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Token $_token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 204) {
      _documents.removeWhere((document) => document.id == documentId);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete document')),
      );
    }
  }

  // Set the document name
  void setDocumentName(String name) {
    _documentName = name;
    notifyListeners();
  }

  // Register a new user
  Future<void> register(
      BuildContext context,
      String username,
      String firstName,
      String lastName,
      String email,
      String password,
      String confirmPassword,
      ) async {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final url = Uri.parse(registerUrl);
    final response = await http.post(
      url,
      body: json.encode({
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register')),
      );
    }
  }

  // Login a user
  Future<void> login(BuildContext context, String email, String password) async {
    final url = Uri.parse(loginUrl);
    final response = await http.post(
      url,
      body: json.encode({
        'username': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String token = data['token'];
      await updateToken(token);  // Save the token and update state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );
      Navigator.pushReplacementNamed(context, '/');  // Navigate to the home screen
    } else {
      _isAuthenticated = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login')),
      );
    }
  }

  // Fetch document history
  Future<void> fetchDocumentHistory(BuildContext context) async {
    final url = Uri.parse('$documentsUrl/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _documents = data.map((item) => Document.fromJson(item)).toList();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document history fetched successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch document history')),
      );
    }
  }

  // Fetch content of a specific document
  Future<void> fetchDocumentContent(BuildContext context, int documentId) async {
    final url = Uri.parse('$documentsUrl/$documentId/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _currentDocument = Document.fromJson(data);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document content fetched successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch document content')),
      );
    }
  }

  // Improve the content of a specific document
  Future<void> improveDocument(BuildContext context, int documentId) async {
    final url = Uri.parse('$documentsUrl/$documentId/improve/');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _currentDocument = Document.fromJson(data);
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document improved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to improve document')),
      );
    }
  }

  // Accept suggestions for a specific document
  Future<void> acceptSuggestions(BuildContext context, int documentId) async {
    final url = Uri.parse('$documentsUrl/$documentId/accept/');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggestions accepted successfully')),
      );
      fetchDocumentContent(context, documentId); // Refresh document content
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept suggestions')),
      );
    }
  }

  // Reject suggestions for a specific document
  Future<void> rejectSuggestions(BuildContext context, int documentId) async {
    final url = Uri.parse('$documentsUrl/$documentId/reject/');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggestions rejected successfully')),
      );
      fetchDocumentContent(context, documentId); // Refresh document content
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject suggestions')),
      );
    }
  }

  // Clear the current document
  void clearCurrentDocument() {
    _currentDocument = null;
    _isUploaded = false; // Mark as not uploaded
    _documentName = null; // Clear the document name
    notifyListeners();
  }

  // Clear the current document content
  void clearDocumentContent() {
    if (_currentDocument != null) {
      _currentDocument = Document(
        id: _currentDocument!.id,
        name: _currentDocument!.name,
        originalContent: '',
        improvedContent: '',
        status: _currentDocument!.status,
        uploadDate: '',
      );
    }
    notifyListeners();
  }
}
