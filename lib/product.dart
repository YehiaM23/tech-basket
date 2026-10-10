import 'dart:convert';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image, name, price;
  final bool showHeart, isAsset, favorite;
  final VoidCallback? onHeartTap;
  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    this.showHeart = false,
    this.isAsset = true,
    this.favorite = false,
    this.onHeartTap,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff1f0fa),
              borderRadius: BorderRadius.circular(20),
            ),
            child: isAsset
                ? Image.asset(image, fit: BoxFit.contain)
                : Image.memory(base64Decode(image), fit: BoxFit.contain),
          ),
          if (showHeart)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                tooltip: 'Favorite',
                onPressed: onHeartTap,
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.deepPurple,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(
        price,
        style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
      ),
    ],
  );
}
