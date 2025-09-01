// Supporting Widgets and Classes
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Save the result to the specified collection in Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('collections')
        .doc(collection)
        .collection('items')
        .doc(result.id)
        .set(result.toJson())
        .then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $collection collection')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $error')),
      );
    });
  }

  void _createNewCollection(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Collection'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Collection Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not authenticated')),
                  );
                  return;
                }

                // Create a new collection document in Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('collections')
                    .doc(name)
                    .set({'createdAt': Timestamp.now()}).then((_) {
                  Navigator.of(dialogContext).pop();
                  Navigator.pop(context); // Close the bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Collection $name created')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}
