import 'package:animal/organzations_page.dart';
import 'package:animal/pets.dart';
import 'package:animal/upload.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'profile.dart'; // Assume you have a Profile screen widget
import 'package:firebase_auth/firebase_auth.dart';

class NavbarScreen extends StatefulWidget {
  final User user;

  const NavbarScreen({super.key, required this.user});

  @override
  _NavbarScreenState createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      Dashboard(user: widget.user),
      OrganizationsPage(),
      AnimalListScreen(),
      UploadScreen(user: widget.user),
      Profile(user: widget.user), // Your profile screen
      
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Color.fromARGB(255, 219, 153, 106),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.corporate_fare),
            label: 'Organizations',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
