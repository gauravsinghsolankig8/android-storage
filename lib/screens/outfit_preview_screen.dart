import 'package:flutter/material.dart';

class OutfitPreviewScreen extends StatelessWidget {
  const OutfitPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Preview')),
      body: const Center(
        child: Text('Outfit Preview - Coming Soon!'),
      ),
    );
  }
}