import 'package:google_generative_ai/google_generative_ai.dart';

final String _apiKey = "AIzaSyDfC4PFU9U4UsAiYsE8F3QD2pCEMJuQrfs";

Future<String?> geminiapirequest(String prompt) async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  final prompt = '';
  final response = await model.generateContent([Content.text(prompt)]);

  print(response.text);

  return response.text;
}
