// Supporting Widgets and Classes
import 'package:flutter/material.dart';

import '../models/detection_result.dart';

class CollectionSelectorSheet extends StatelessWidget {
  final DetectionResult result;

  const CollectionSelectorSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Save to Collection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: const Text('Favorites'),
                  onTap: () => _saveToCollection(context, 'favorites'),
                ),
                ListTile(
                  leading: const Icon(Icons.work, color: Colors.blue),
                  title: const Text('Work Projects'),
                  onTap: () => _saveToCollection(context, 'work'),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.green),
                  title: const Text('Personal'),
                  onTap: () => _saveToCollection(context, 'personal'),
                ),
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.grey),
                  title: const Text('Create New Collection'),
                  onTap: () => _createNewCollection(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveToCollection(BuildContext context, String collection) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to $collection collection')),
    );
  }

  void _createNewCollection(BuildContext context) {
    Navigator.pop(context);
    // Show create collection dialog
  }
}
