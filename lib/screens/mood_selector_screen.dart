import 'package:flutter/material.dart';

class MoodSelectorScreen extends StatelessWidget {
  const MoodSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Mood')),
      body: const Center(
        child: Text('Mood Selector - Coming Soon!'),
      ),
    );
  }
}