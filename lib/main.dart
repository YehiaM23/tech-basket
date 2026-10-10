import 'package:flutter/material.dart';
import 'homepage.dart';
import 'ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tech Basket',
    debugShowCheckedModeBanner: false,
    theme: appTheme(Colors.deepPurple),
    home: const Homepage(),
  );
}
