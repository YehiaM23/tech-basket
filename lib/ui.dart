import 'package:flutter/material.dart';

ThemeData appTheme(Color color) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: color),
  scaffoldBackgroundColor: const Color(0xfff5f7fb),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xfff5f7fb),
    centerTitle: false,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  ),
);

class IntroCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const IntroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 38, color: colors.primary),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
