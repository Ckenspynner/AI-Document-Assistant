import 'package:document_assistant/provider/document_provider.dart'; // Import DocumentProvider for state management
import 'package:document_assistant/screen/document/document_detail_screen.dart'; // Import DocumentDetailScreen
import 'package:document_assistant/screen/document/document_history_screen.dart'; // Import DocumentHistoryScreen
import 'package:document_assistant/screen/document/documentscreen.dart'; // Import DocumentScreen
import 'package:document_assistant/screen/document/userprofile.dart'; // Import UserProfilePage
import 'package:document_assistant/screen/signin/login_screen.dart'; // Import LoginScreen
import 'package:document_assistant/screen/signup/register_screen.dart'; // Import RegisterScreen
import 'package:flutter/material.dart'; // Import Flutter material package
import 'package:provider/provider.dart'; // Import Provider for state management

import 'models/document.dart'; // Import Document model

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DocumentProvider(), // Create and provide DocumentProvider
      child: MyApp(), // MyApp widget as the child
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState(); // Create state for MyApp
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Add post frame callback to check and load token
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentProvider>(context, listen: false).checkAndLoadToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context); // Access DocumentProvider

    return MaterialApp(
      title: 'Document Assistant', // Title of the application
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set primary color to blue
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white, // Set icon color in AppBar to white
          ),
        ),
      ),
      initialRoute: '/', // Initial route of the application
      routes: {
        // Define routes for the application
        '/': (context) => documentProvider.isAuthenticated ? const DocumentScreen() : LoginScreen(), // Home route
        '/register': (context) => RegisterScreen(), // Register route
        '/login': (context) => LoginScreen(), // Login route
        '/history': (context) => DocumentHistoryScreen(), // Document history route
        '/profile': (context) => UserProfilePage(), // User profile route
      },
      onGenerateRoute: (settings) {
        // Handle dynamic route generation
        if (settings.name == '/document_detail') {
          final document = settings.arguments as Document; // Extract document argument
          return MaterialPageRoute(
            builder: (context) {
              return DocumentDetailScreen(document: document); // Navigate to DocumentDetailScreen
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}'); // Assert false if route not implemented
        return null;
      },
    );
  }
}
