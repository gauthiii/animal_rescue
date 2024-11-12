import 'package:animal/pets.dart';
import 'package:animal/profile.dart';
import 'package:animal/reports.dart';
import 'package:animal/upload.dart';
import 'package:animal/yolo.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animal/organzations_page.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'login_page.dart';

class Dashboard extends StatefulWidget {
  final User user;

  const Dashboard({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _Ds createState() => _Ds();
}

class _Ds extends State<Dashboard> {

  @override
  void initState() {
    super.initState();
  
  }



 

 

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 35, 35),
        title: const Text(
          'Animal Rescue Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
        
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/wall2.png'),
            opacity: 0.7,
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
              
                const SizedBox(height: 10),
               Stack(
  children: [
    // Outer text for stroke effect
    Text(
      'Services',
      style: TextStyle(
        fontSize: 70,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 // Adjust stroke width as needed
          ..color = Color.fromARGB(255, 219, 153, 106), // Stroke color
      ),
    ),
    // Inner text for fill
    Text(
      'Services',
      style: TextStyle(
        fontSize: 70,
        fontWeight: FontWeight.bold,
        fontFamily: "Bangers",
        color: Color.fromARGB(255, 7, 7, 7), // Fill color
      ),
    ),
  ],
),

                
                const SizedBox(height: 10),
           
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(

                        minimumSize: Size.fromHeight(60),
                        backgroundColor: Colors.black,
                        
                      
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrganizationsPage()),
                        );
                      },
                      child: const Text('Nearby Organizations',style: TextStyle(color: Color.fromARGB(255, 219, 153, 106),fontSize: 17),),
                    ),
                    const SizedBox(height: 20),
                     ElevatedButton(
                      style: ElevatedButton.styleFrom(

                        minimumSize: Size.fromHeight(60),
                        backgroundColor: Colors.black,
                        
                      
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AnimalListScreen()),
                        );
                      },
                      child: const Text('Find Pets',style: TextStyle(color: Color.fromARGB(255, 219, 153, 106),fontSize: 17),),
                    ),
                    const SizedBox(height: 20),
                     ElevatedButton(
                      style: ElevatedButton.styleFrom(

                        minimumSize: Size.fromHeight(60),
                        backgroundColor: Colors.black,
                        
                      
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UploadScreen(user: widget.user)),
                        );
                      },
                      child: const Text('Update Agency',style: TextStyle(color: Color.fromARGB(255, 219, 153, 106),fontSize: 17),),
                    ),
                    const SizedBox(height: 10),
                      ElevatedButton(
                      style: ElevatedButton.styleFrom(

                        minimumSize: Size.fromHeight(60),
                        backgroundColor: Colors.black,
                        
                      
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ObjectDetectionScreen()),
                        );
                      },
                      child: const Text('Yolo Model',style: TextStyle(color: Color.fromARGB(255, 219, 153, 106),fontSize: 17),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(

                        minimumSize: Size.fromHeight(60),
                        backgroundColor: Colors.black,
                        
                      
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ReportScreen()),
                        );
                      },
                      child: const Text('My Reports',style: TextStyle(color: Color.fromARGB(255, 219, 153, 106),fontSize: 17),),
                    ),
                    const SizedBox(height: 10),
                
              ],
            ),
          ),
        ),
      ),
    ) ;
  }
}
