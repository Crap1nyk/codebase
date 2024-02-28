
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/basic_page.dart';
import 'package:flutter_application_1/pages/custom_page.dart';
import 'package:flutter_application_1/pages/from_gallery_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.teal,
      ),
      title: 'Flutter Document Scanner',
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // * Basic example page
                  ElevatedButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const BasicPage(),
                      ),
                    ),
                    child: const Text(
                      'Basic example',
                    ),
                  ),

                  // * Custom example page
                  ElevatedButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomPage(),
                      ),
                    ),
                    child: const Text(
                      'Custom example',
                    ),
                  ),

                  // * From gallery example page
                  ElevatedButton(
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FromGalleryPage(),
                      ),
                    ),
                    child: const Text(
                      'From gallery example',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}