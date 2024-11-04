import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class UploadScreen extends StatefulWidget {
  final User user;

  const UploadScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  Map<String, dynamic>? Animal_User;
  bool isLoading = false;

Future<void> _fetchUserDetails() async {
   setState(() {
      isLoading = true;
    });

  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('animal_users')  // Replace with your actual collection name
      .doc(widget.user.uid)
      .get();

  if (userDoc.exists) {
    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
    setState(() {
      Animal_User = {
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'mobile': data['mobile'] ?? '',
      };

      print(Animal_User);

      // Assign the fetched data to the text fields
      // _nameController.text = Animal_User['name'] as String;
      // _mobileController.text = Animal_User['mobile'] as String;
    });
  }

   setState(() {
      isLoading = false;
    });
}


@override
void initState() {
  super.initState();
  _fetchUserDetails();
}



  File? _selectedImage;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _category;
  String? _animal;
  String? _urgencyLevel;
  String? _actionRequired;

  final List<String> _categories = ['Endangered', 'Dangerous', 'Stray'];
  final List<String> _animals = ['Dog', 'Cat', 'Horse', 'Bird', 'Snake'];
  final List<String> _urgencyLevels = ['Priority', 'Low Risk', 'Moderate'];
  final List<String> _actions = ['Send Rescue Team', 'Connect NGO', 'Leave as Observation', 'Notify Police'];


  Future<String?> _uploadImageToStorage(File image) async {
  try {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('animal_alert_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}

Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
         AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        minimumAspectRatio: 1.0,
      )

      ]
    );

    if (croppedImage != null) {
      setState(() {
        _selectedImage = File(croppedImage.path);
      });
    }
  }
}

  Future<void> _submitData() async {
     setState(() {
      isLoading = true;
    });

  if (_selectedImage == null ||
      _category == null ||
      _animal == null ||
      _urgencyLevel == null ||
      _actionRequired == null ||
      _locationController.text.isEmpty ||
      _descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields and upload an image.')),
    );
    return;
  }

  String? imageUrl = await _uploadImageToStorage(_selectedImage!);
  if (imageUrl == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to upload image. Please try again.')),
    );
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('animal_alerts').add({
      'category': _category,
      'animal': _animal,
      'location': _locationController.text,
      'urgencyLevel': _urgencyLevel,
      'uploaderName': Animal_User?['name'],
      'uploaderContact': Animal_User?['mobile'],
      'uploaderEmail': Animal_User?['email'],
      'description': _descriptionController.text,
      'actionRequired': _actionRequired,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,  // Add this line for the image URL
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert submitted successfully!')),
    );
    _clearForm();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error submitting alert: $e')),
    );
  }

   setState(() {
      isLoading = false;
    });
}


  void _clearForm() {
    setState(() {
      _selectedImage = null;
      _category = null;
      _animal = null;
      _urgencyLevel = null;
      _actionRequired = null;
      _locationController.clear();
      _descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Animal Alert'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
                  ?  const SizedBox( height:10, child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ))
                  :  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child:Padding(
                  padding:EdgeInsets.symmetric(horizontal: 80,vertical: 0) ,
                  child: AspectRatio(aspectRatio: 1,child: Container(
                  color: Colors.grey[300],
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Center(child: Text('Tap to upload image\n(1:1 ratio)',style: TextStyle(fontSize: 12),textAlign: TextAlign.center,)),
                ))),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                hint: const Text('Select Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _animal,
                hint: const Text('Select Animal'),
                items: _animals.map((String animal) {
                  return DropdownMenuItem<String>(
                    value: animal,
                    child: Text(animal),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _animal = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _urgencyLevel,
                hint: const Text('Select Urgency Level'),
                items: _urgencyLevels.map((String urgency) {
                  return DropdownMenuItem<String>(
                    value: urgency,
                    child: Text(urgency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _urgencyLevel = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _actionRequired,
                hint: const Text('Select Action Required'),
                items: _actions.map((String action) {
                  return DropdownMenuItem<String>(
                    value: action,
                    child: Text(action),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _actionRequired = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  child: const Text('Submit Alert'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
