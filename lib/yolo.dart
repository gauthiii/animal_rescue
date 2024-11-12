import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  Interpreter? _interpreter;
  File? _image;
  final picker = ImagePicker();
  bool _loading = false;
  List<Map<String, dynamic>> _detections = [];
  bool _isInjuredDetected = false; // Track if any detection is "injured"

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    setState(() {
      _loading = true;
    });
    _interpreter = await Interpreter.fromAsset('images/yolov8n.tflite');
    setState(() {
      _loading = false;
    });
  }

  Future<void> detectObjects(File image) async {
    final rawImage = img.decodeImage(image.readAsBytesSync());
    final resizedImage = img.copyResize(rawImage!, width: 640, height: 640);

    // Convert the image to a normalized Float32 List
    var input = imageToByteListFloat32(resizedImage, 640, 640);

    // Adjust output shape to [1, 84, 8400] based on the model's actual output
    var output = List.generate(1, (i) => List.generate(84, (j) => List.filled(8400, 0.0)));

    // Run inference
    _interpreter?.run(input, output);

    // Process the output to extract boxes, classes, and scores
    var results = processOutput(output);

    setState(() {
      _detections = results;
      print("*******************************************");
      print(_detections);
      print("*******************************************");
      _loading = false;
    });
  }

  List<Map<String, dynamic>> processOutput(List<List<List<double>>> output) {
    List<Map<String, dynamic>> detections = [];
    bool injuredDetected = false; // Track if any detection is "injured"

    // Adjust processing based on the new output shape [1, 84, 8400]
    for (var i = 0; i < output[0][0].length; i++) {
      double confidence = output[0][4][i];  // Confidence score is in the 5th index (index 4)

      if (confidence > 0.5) {
        var x = output[0][0][i];
        var y = output[0][1][i];
        var width = output[0][2][i];
        var height = output[0][3][i];
        var classId = output[0][5][i].toInt();  // Adjust classId index if necessary

        if (classId == 5) { // Assuming class ID 5 represents "injured"
          injuredDetected = true;
        }

        detections.add({
          'classId': classId,
          'confidence': confidence,
          'boundingBox': Rect.fromLTWH(x - width / 2, y - height / 2, width, height),
        });
      }
    }

    // Add the injured status to state to display in the UI
    setState(() {
      _isInjuredDetected = injuredDetected;
      print("Injured detected: $_isInjuredDetected");
    });

    return detections;
  }

  Uint8List imageToByteListFloat32(img.Image image, int width, int height) {
    var convertedBytes = Float32List(1 * width * height * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (final pixel in image) {
      // Access the red, green, and blue channels directly from the pixel
      buffer[pixelIndex++] = pixel.r / 255.0; // Red
      buffer[pixelIndex++] = pixel.g / 255.0; // Green
      buffer[pixelIndex++] = pixel.b / 255.0; // Blue
    }

    return convertedBytes.buffer.asUint8List();
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _loading = true;
      });
      detectObjects(_image!).catchError((e){
        print("************************************");
        print(e.toString());
        print("************************************");

        setState(() {
          _loading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Object Detection"),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_image != null)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Stack(
                        children: _detections.map((det) {
                          return Positioned(
                            left: det['boundingBox'].left,
                            top: det['boundingBox'].top,
                            width: det['boundingBox'].width,
                            height: det['boundingBox'].height,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Text(
                                'ID: ${det['classId']} (${(det['confidence'] * 100).toStringAsFixed(0)}%)',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                if (_image == null)
                  Expanded(
                    child: Center(
                      child: Text("Select an image to detect objects"),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: pickImage,
                    child: Text("Pick Image from Gallery"),
                  ),
                ),
                if (_detections.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _isInjuredDetected ? "Injured animal detected!" : "No injury detected.",
                      style: TextStyle(fontSize: 18, color: _isInjuredDetected ? Colors.red : Colors.green),
                    ),
                  ),

                   if (_detections.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                       "No injury detected.",
                      style: TextStyle(fontSize: 18, color: _isInjuredDetected ? Colors.red : Colors.green),
                    ),
                  ),
              ],
            ),
    );
  }
}
