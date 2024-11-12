import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  Interpreter? _interpreter;
  double? _predictionLat;
  double? _predictionLong;

  // Dropdown selections
  String _selectedUrgency = 'low';
  String _selectedAnimal = 'dog';

  // Encodings for model input
  Map<String, double> urgencyEncoding = {'low': 0.0, 'moderate': 1.0, 'high': 2.0};
  Map<String, double> animalEncoding = {'dog': 0.0, 'cat': 1.0, 'snake': 2.0, 'rabbit': 3.0};

  // Example mapping of class indices to coordinates (replace with actual values)
 final Map<int, List<double>> classToCoordinates = {
  0: [13.0827, 80.2707],
  1: [13.0616, 80.2478],
  2: [13.0582, 80.2344],
  3: [13.0360, 80.2144],
  4: [13.0420, 80.2542],
  5: [13.0627, 80.1996],
  6: [13.0368, 80.1892],
  7: [13.0921, 80.2120],
  8: [13.0736, 80.2717],
  9: [13.0795, 80.2016],
  10: [13.0492, 80.2483],
  11: [13.0432, 80.2754],
  12: [13.0831, 80.2366],
  13: [13.0628, 80.2901],
  14: [13.0952, 80.2583],
  15: [13.0719, 80.2214],
  16: [13.0872, 80.2245],
  17: [13.0651, 80.2388],
  18: [13.0724, 80.2609],
  19: [13.0525, 80.2097],
  20: [13.0905, 80.2429],
  21: [13.0668, 80.2276],
  22: [13.0734, 80.2125],
  23: [13.0548, 80.2248],
  24: [13.0776, 80.2673],
  25: [13.0632, 80.2307],
  26: [13.0845, 80.2554],
  27: [13.0485, 80.2067],
  28: [13.0883, 80.2728],
  29: [13.0512, 80.2171],
  30: [13.0644, 80.2415],
  31: [13.0608, 80.2537],
  32: [13.0862, 80.2289],
  33: [13.0553, 80.2154],
  34: [13.0758, 80.2456],
  35: [13.0686, 80.2602],
  36: [13.0671, 80.2688],
  37: [13.0929, 80.2345],
  38: [13.0731, 80.2234],
  39: [13.0789, 80.2383],
  40: [13.0813, 80.2631],
  41: [13.0568, 80.2519],
  42: [13.0896, 80.2468],
  43: [13.0625, 80.2641],
  44: [13.0598, 80.2024],
  45: [13.0825, 80.2507],
  46: [13.0559, 80.2176],
  47: [13.0637, 80.2112],
  48: [13.0793, 80.2568],
  49: [13.0722, 80.2435],
  50: [13.0708, 80.2714],
  51: [13.0592, 80.2295],
  52: [13.0648, 80.2562],
  53: [13.0752, 80.2665],
  54: [13.0537, 80.2192],
  55: [13.0805, 80.2521],
  56: [13.0909, 80.2656],
  57: [13.0881, 80.2196],
  58: [13.0683, 80.2752],
  59: [13.0772, 80.2088],
  60: [13.0541, 80.2283],
  61: [13.0851, 80.2041],
  62: [13.0661, 80.2505],
  63: [13.0737, 80.2132],
  64: [13.0802, 80.2488],
  65: [13.0615, 80.2352],
  66: [13.0918, 80.2221],
  67: [13.0741, 80.2335],
  68: [13.0521, 80.2218],
  69: [13.0879, 80.2421],
  70: [13.0687, 80.2128],
  71: [13.0815, 80.2414],
  72: [13.0761, 80.2239],
  73: [13.0586, 80.2618],
  74: [13.0564, 80.2163],
  75: [13.0834, 80.2702],
  76: [13.0545, 80.2439],
  77: [13.0798, 80.2261],
  78: [13.0664, 80.2711],
  79: [13.0902, 80.2248],
  80: [13.0621, 80.2204],
  81: [13.0596, 80.2549],
  82: [13.0711, 80.2571],
  83: [13.0694, 80.2623],
  84: [13.0847, 80.2286],
  85: [13.0572, 80.2665],
  86: [13.0766, 80.2192],
  87: [13.0895, 80.2318],
  88: [13.0517, 80.2095],
  89: [13.0868, 80.2404],
  90: [13.0623, 80.2532],
  91: [13.0579, 80.2339],
  92: [13.0645, 80.2628],
  93: [13.0702, 80.2241],
  94: [13.0657, 80.2317],
  95: [13.0755, 80.2672],
  96: [13.0783, 80.2332],
  97: [13.0908, 80.2384],
  98: [13.0859, 80.2573],
  99: [13.0676, 80.2081],
  // Repeat with similar latitude and longitude values for up to index 301
};

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      // Load the TensorFlow Lite model
      _interpreter = await Interpreter.fromAsset('images/model.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  void runModel() async {
    if (_interpreter == null) return;

    setState(() {
  // Define a latitude and longitude range around Chennai (approximately)
  double minLat = 13.0;
  double maxLat = 13.1;
  double minLong = 80.1;
  double maxLong = 80.3;

  // Generate random latitude and longitude within the defined range
  _predictionLat = minLat + Random().nextDouble() * (maxLat - minLat);
  _predictionLong = minLong + Random().nextDouble() * (maxLong - minLong);
});

    // Prepare input based on dropdown selections
    double urgency = urgencyEncoding[_selectedUrgency] ?? 0.0;
    double animal = animalEncoding[_selectedAnimal] ?? 0.0;
    double urgencyAnimalInteraction = urgency * animal; // Interaction term

    var input = [
      [urgency, animal, urgencyAnimalInteraction]
    ];

    // Adjust output to match the model's output shape: [1, 302]
    var output = List.filled(1, List.filled(302, 0.0)).reshape([1, 302]);

    // Run inference
    _interpreter!.run(input, output);

    // Get the index of the class with the highest probability
    int predictedClass = output[0].indexWhere((prob) => prob == output[0].reduce(max));

    // Map the predicted class to coordinates
    List<double>? coordinates = classToCoordinates[predictedClass];

    if (coordinates != null) {
      setState(() {
        _predictionLat = coordinates[0];
        _predictionLong = coordinates[1];
      });

      openMap(_predictionLat!, _predictionLong!);
    } else {
      print("Prediction out of bounds");
    }
  }

  Future<void> openMap(double latitude, double longitude) async {

    MapsLauncher.launchCoordinates(latitude, longitude);

  //   // Use the Geolocator to open maps at the predicted location
  //   await Geolocator.openLocationSettings();
  //   await Geolocator.openAppSettings();
  //   // Or open directly in Maps:
  //   // "geo:$latitude,$longitude" launches the device's maps app at the predicted coordinates
  //   await Geolocator.openLocationSettings();
  // 
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
        title: Text('Prediction Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select Inputs for Prediction',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            
            // Dropdown for Urgency Level
            DropdownButtonFormField<String>(
              value: _selectedUrgency,
              decoration: InputDecoration(labelText: 'Urgency Level'),
              items: urgencyEncoding.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedUrgency = newValue!;
                });
              },
            ),
            
            // Dropdown for Animal Type
            DropdownButtonFormField<String>(
              value: _selectedAnimal,
              decoration: InputDecoration(labelText: 'Animal Type'),
              items: animalEncoding.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedAnimal = newValue!;
                });
              },
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: runModel,
              child: Text('Predict'),
            ),
            SizedBox(height: 20),
            
            // Show the Prediction Results
            if (_predictionLat != null && _predictionLong != null)
              Text(
                'Predicted Location:\nLatitude: $_predictionLat\nLongitude: $_predictionLong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

                SizedBox(height: 20),

              if (_predictionLat != null && _predictionLong != null)
              ElevatedButton(
              onPressed: (){
                openMap(_predictionLat!, _predictionLong!);
              },
              child: Text('Open Map'),
            ),
          ],
        ),
      ),
    );
  }
}
