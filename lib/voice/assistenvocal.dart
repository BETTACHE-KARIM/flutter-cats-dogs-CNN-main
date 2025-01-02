import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';

class Assistenvocal extends StatefulWidget {
  const Assistenvocal({super.key});

  @override
  State<Assistenvocal> createState() => _AssistenvocalState();
}

class _AssistenvocalState extends State<Assistenvocal> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _apiResponse = '';
  bool _isListening = false;

  final String _apiKey = "AIzaSyDfC4PFU9U4UsAiYsE8F3QD2pCEMJuQrfs";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      try {
        _speechEnabled = await _speechToText.initialize(
          onStatus: (status) {
            debugPrint('Speech status: $status');
          },
          onError: (error) {
            debugPrint('Speech error: ${error.errorMsg}');
          },
        );
        if (!_speechEnabled) {
          debugPrint('Speech recognition initialization failed');
        }
      } catch (e) {
        debugPrint('Speech recognition initialization exception: $e');
      }
      setState(() {}); // Update UI based on `_speechEnabled`
    } else {
      debugPrint('Microphone permission denied');
    }
  }

  void _startListening() async {
    if (_speechEnabled && !_isListening) {
      try {
        await _speechToText.listen(onResult: _onSpeechResult);
        setState(() {
          _isListening = true;
        });
      } catch (e) {
        debugPrint('Error starting speech recognition: $e');
      }
    } else {
      debugPrint('Speech recognition not enabled or already listening');
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });

    if (_lastWords.isNotEmpty) {
      await _sendToGemini(_lastWords);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  Future<void> _sendToGemini(String prompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _apiResponse = response.text ?? 'No response from the model';
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Update the "Tap to Talk" text color based on the listening state
            Text(
              'Tap to Talk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isListening
                    ? Colors.green
                    : Colors.black, // Change color to green when listening
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(
              value: _lastWords,
              hintText: 'Recognized speech will appear here',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              value: _apiResponse,
              hintText: 'API response will appear here',
            ),
            const SizedBox(height: 50),
            IconButton(
              icon: Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 60,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _startListening();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String value,
    required String hintText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        maxLines: null,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.black54),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }
}
