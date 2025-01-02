import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // For loading asset images
import 'package:path_provider/path_provider.dart'; // For saving to temporary directory
import 'package:gal/gal.dart'; // For saving images to gallery
import 'dart:developer' as devtools;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? filePath;
  String label = '';
  double confidence = 0.0;

  Future<void> _tfLteInit() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  // Function to save apple.png from assets to the gallery
  Future<void> saveAppleImageToGallery() async {
    try {
      // Load the image from assets
      final byteData = await rootBundle.load('assets/cat.jpg');
      final buffer = byteData.buffer.asUint8List();

      // Get the temporary directory to save the image
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/cat.jpg');

      // Write the image data to the temporary file
      await tempFile.writeAsBytes(buffer);

      // Save the image to the gallery
      await Gal.putImage(tempFile.path);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image saved to gallery!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error saving image: $e")));
    }
  }

  bool _isModelBusy = false;

  pickImageGallery() async {
    if (_isModelBusy) {
      devtools.log("Interpreter is busy. Please wait.");
      return;
    }

    // Pick the image from the gallery
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    _isModelBusy = true; // Mark the model as busy before starting inference

    try {
      // Run model inference
      var recognitions = await Tflite.runModelOnImage(
          path: image.path, // required
          imageMean: 0.0, // defaults to 117.0
          imageStd: 255.0, // defaults to 1.0
          numResults: 2, // defaults to 5
          threshold: 0.2, // defaults to 0.1
          asynch: true // defaults to true
          );

      if (recognitions == null || recognitions.isEmpty) {
        devtools.log("recognitions is Null or empty");
        return;
      }

      devtools.log(recognitions.toString());
      setState(() {
        confidence = (recognitions[0]['confidence'] * 100);
        label = recognitions[0]['label'].toString();
      });
    } catch (e) {
      devtools.log("Error during model inference: $e");
    } finally {
      _isModelBusy = false; // Reset the flag after processing
    }
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    super.initState();
    _tfLteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (filePath != null)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Card(
                    elevation: 20,
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 350,
                          width: double.infinity,
                          child: Image.file(
                            filePath!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "Label: $label",
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Confidence: ${confidence.toStringAsFixed(2)}%",
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(68.0),
                  child: Image.asset(
                    "assets/catdog_transparent.png",
                    // fit: BoxFit.contain,
                    // width: 250,
                  ),
                ),
              ElevatedButton.icon(
                onPressed: saveAppleImageToGallery,
                label: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text("Save Apple Image to Gallery"),
                ),
                icon: const Icon(Icons.save_alt),
              ),
              ElevatedButton.icon(
                  onPressed: pickImageGallery,
                  label: const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text("Pick an Image"),
                  ),
                  icon: const Icon(Icons.image)),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
