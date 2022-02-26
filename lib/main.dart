import 'package:flutter/material.dart';
import 'package:contact_list/contact_list.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() {
    FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) { // handle errors
      exit(1);
    }
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Contact list',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactList(),
    );
  }
}
