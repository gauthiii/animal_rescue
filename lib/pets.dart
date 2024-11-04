import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalListScreen extends StatelessWidget {
  const AnimalListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Alerts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animal_alerts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No animal alerts found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var alertData = snapshot.data!.docs[index];
              return  Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (alertData['imageUrl'] != null)
                        Image.network(
                          alertData['imageUrl'],
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Category: ${alertData['category']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Animal: ${alertData['animal']}'),
                      Text('Location: ${alertData['location']}'),
                      Text('Urgency Level: ${alertData['urgencyLevel']}'),
                      const SizedBox(height: 4),
                      Text(
                        'Description: ${alertData['description']}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      Text('Action Required: ${alertData['actionRequired']}'),
                      const Divider(),
                      Text('Uploaded by: ${alertData['uploaderName']}'),
                      Text('Contact: ${alertData['uploaderContact']}'),
                      Text('Email: ${alertData['uploaderEmail']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
