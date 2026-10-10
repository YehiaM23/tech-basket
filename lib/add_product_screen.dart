import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(), price = TextEditingController();
  Uint8List? image;
  String category = 'Phones';
  Future<void> pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 1000000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose an image smaller than 1 MB.')),
        );
        return;
      }
      setState(() => image = bytes);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not select the image. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add product')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        InkWell(
          onTap: pickImage,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: image == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 48),
                      Text('Choose product image'),
                    ],
                  )
                : Image.memory(image!, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$ ',
                ),
                validator: (v) {
                  final number = double.tryParse(v ?? '');
                  return number == null || !number.isFinite || number <= 0
                      ? 'Enter a positive price'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Phones', 'Laptops', 'Accessories']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            if (image == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Choose an image first')),
              );
              return;
            }
            Navigator.pop(context, <String, dynamic>{
              'name': name.text.trim(),
              'price': double.parse(price.text),
              'image': base64Encode(image!),
              'category': category,
              'isAsset': false,
              'favorite': false,
              'quantity': 0,
            });
          },
          child: const Text('Save product'),
        ),
      ],
    ),
  );
}
