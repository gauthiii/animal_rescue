import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:animal/organzations_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';

class Profile extends StatefulWidget {
  final User user;

  const Profile({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _Ds createState() => _Ds();
}

class _Ds extends State<Profile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isUpdating = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('animal_users')
        .doc(widget.user.uid)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _mobileController.text = data['mobile'] ?? '';
        _emailController.text = data['email'] ?? '';
        _isUpdating = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be at least 3 characters long.')),
      );
      return;
    }
    if (_mobileController.text.length != 10 && !_mobileController.text.contains(RegExp(r'^[0-9]+\$'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile number must be a valid 10-digit number.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('animal_users').doc(widget.user.uid).set({
      'name': _nameController.text,
      'mobile': _mobileController.text,
      'email': widget.user.email,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isUpdating ? 'Details Updated' : 'Details Saved')),
    );

    setState(() {
      _isUpdating = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading:false,
        backgroundColor: const Color.fromARGB(255, 37, 35, 35),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _signOut(context);
            },
            icon: const Icon(Icons.input, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/wall2.png'),
            opacity: 0.7,
            fit: BoxFit.cover,
          ),
        ),
        child:  isLoading
                  ?  const SizedBox( height:10, child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ))
                  :  SingleChildScrollView(
          child: RefreshIndicator(onRefresh: _loadUserData, child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(padding: EdgeInsets.only(left:10),child: Stack(
  children: [
    // Outer text for stroke effect
    Text(
      'Full Name',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 // Adjust stroke width as needed
          ..color = Color.fromARGB(255, 219, 153, 106), // Stroke color
      ),
    ),
    // Inner text for fill
    Text(
      'Full Name',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        color: Color.fromARGB(255, 7, 7, 7), // Fill color
      ),
    ),
  ],
)),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 14, 101, 172), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(padding: EdgeInsets.only(left:10),child: Stack(
  children: [
    // Outer text for stroke effect
    Text(
      'Mobile Number',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 // Adjust stroke width as needed
          ..color = Color.fromARGB(255, 219, 153, 106), // Stroke color
      ),
    ),
    // Inner text for fill
    Text(
      'Mobile Number',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        color: Color.fromARGB(255, 7, 7, 7), // Fill color
      ),
    ),
  ],
)),
                TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 14, 101, 172), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                Padding(padding: EdgeInsets.only(left:10),child: Stack(
  children: [
    // Outer text for stroke effect
    Text(
      'Email Address (CANNOT BE ALTERED)',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 // Adjust stroke width as needed
          ..color = Color.fromARGB(255, 219, 153, 106), // Stroke color
      ),
    ),
    // Inner text for fill
    Text(
      'Email Address (CANNOT BE ALTERED)',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        color: Color.fromARGB(255, 7, 7, 7), // Fill color
      ),
    ),
  ],
)),
                TextField(
                  controller: _emailController,
                  readOnly: true,
                  style: TextStyle(color: Color.fromARGB(255, 97, 82, 73)),
                  decoration: InputDecoration(
                
                    filled: true,
                    fillColor: Color.fromARGB(255, 234, 215, 199),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 14, 101, 172), width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveUserData,
                  child: Text(_isUpdating ? 'Update Details' : 'Save Details'),
                ),
                const SizedBox(height: 10),
                
              ],
            ),
          )),
        ),
      ),
    ) ;
  }
}
