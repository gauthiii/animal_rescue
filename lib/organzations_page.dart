import 'package:flutter/material.dart';

class OrganizationsPage extends StatelessWidget {
  final List<Map<String, String>> organizations = [
    {
      'name': 'Animal Shelter A',
      'contact': '123-456-7890',
      'photo': 'images/1.webp',
      'status': 'Active',
    },
    {
      'name': 'Animal Rescue Center B',
      'contact': '987-654-3210',
      'photo': 'images/2.webp',
      'status': 'Inactive',
    },
    {
      'name': 'Saidapet Rescue Center C',
      'contact': '923-354-3410',
      'photo': 'images/3.webp',
      'status': 'Active',
    },
    {
      'name': 'Guindy Doghouse Center D',
      'contact': '677-345-1934',
      'photo': 'images/4.webp',
      'status': 'Inactive',
    },
    {
      'name': 'Velachery Rescue Center E',
      'contact': '897-654-3829',
      'photo': 'images/5.webp',
      'status': 'Inactive',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Organizations'),
      ),
      body:  ListView.builder(
        itemCount: organizations.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.asset(organizations[index]['photo']!),
              title: Text(organizations[index]['name']!),
              subtitle: Text('Contact: ${organizations[index]['contact']}\nStatus: ${organizations[index]['status']}'),
            ),
          );
        },
      ),
    );
  }
}
