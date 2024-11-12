import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class OrganizationsPage extends StatefulWidget {
  @override
  _OrganizationsPageState createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {
  final List<Map<String, String>> dummyOrganizations = [
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
    // {
    //   'name': 'Saidapet Rescue Center C',
    //   'contact': '923-354-3410',
    //   'photo': 'images/3.webp',
    //   'status': 'Active',
    // },
    // {
    //   'name': 'Guindy Doghouse Center D',
    //   'contact': '677-345-1934',
    //   'photo': 'images/4.webp',
    //   'status': 'Inactive',
    // },
    // {
    //   'name': 'Velachery Rescue Center E',
    //   'contact': '897-654-3829',
    //   'photo': 'images/5.webp',
    //   'status': 'Inactive',
    // },
  ];

  List<Map<String, dynamic>> organizations = [];
  bool isLoading = true;
  bool isUploading = false;
  bool isAdd = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String? _status;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchOrganizations();
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance.collection('animal_organizations').get();
      final fetchedOrganizations = snapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        organizations = [...dummyOrganizations, ...fetchedOrganizations];
      });
    } catch (e) {
      print('Error fetching organizations: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
         uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(minimumAspectRatio: 1.0)
        ],
      );
      if (croppedImage != null) {
        setState(() {
          _selectedImage = File(croppedImage.path);
        });
      }
    }
  }

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('organization_photos')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addOrganization() async {
    if (_nameController.text.isEmpty || _contactController.text.isEmpty || _status == null || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and upload an image.')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    final imageUrl = await _uploadImageToStorage(_selectedImage!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed. Please try again.')),
      );
      setState(() {
        isUploading = false;
      });
      return;
    }

    final newOrganization = {
      'name': _nameController.text,
      'contact': _contactController.text,
      'photo': imageUrl,
      'status': _status,
    };

    try {
      await FirebaseFirestore.instance.collection('animal_organizations').add(newOrganization);
      setState(() {
        organizations.add(newOrganization);
        _nameController.clear();
        _contactController.clear();
        _selectedImage = null;
        _status = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organization added successfully!')),
      );
    } catch (e) {
      print('Error adding organization: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add organization.')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }

     setState(() {
                           isAdd=false;
                         });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Organizations'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isAdd ?
          Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ListView(
                                  
                                  children: [
                                    const Text('Add New Organization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(labelText: 'Organization Name'),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _contactController,
                                      decoration: InputDecoration(labelText: 'Contact Number'),
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _status,
                                      items: ['Active', 'Inactive']
                                          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                          .toList(),
                                      onChanged: (value) => setState(() => _status = value),
                                      decoration: InputDecoration(labelText: 'Status'),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          width: 100,
                                          color: Colors.grey[300],
                                          child: _selectedImage != null
                                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                              : const Center(child: Text('Tap to upload image\n(1:1 ratio)', textAlign: TextAlign.center)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: isUploading
                                          ? CircularProgressIndicator()
                                          : ElevatedButton(
                                              onPressed: _addOrganization,
                                              child: const Text('Add Organization'),
                                            ),
                                    ),
                                  ],
                                ),
                              ) 
          :ListView(
              children: [
                for (var organization in organizations)
                  Card(
                    child: ListTile(
                      leading: organization['photo']!.startsWith('images/')
    ? Image.asset(
        organization['photo']!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      )
    : Image.network(
        organization['photo']!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
                      title: Text(organization['name']),
                      subtitle: Text('Contact: ${organization['contact']}\nStatus: ${organization['status']}'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                         setState(() {
                           isAdd=true;
                         });
                        },
                        child: Text('Add Organization'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
