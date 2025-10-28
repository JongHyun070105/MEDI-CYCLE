import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final result = await _recognizer.processImage(inputImage);
    final text = result.text;
    return text;
  }

  Future<List<String>> extractCandidateDrugNames(String text) async {
    final Set<String> found = {};
    final lines = text.split('\n');
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      // 간단한 후보 규칙: 한글/영문/숫자/공백/괄호/하이픈, 길이 2~40
      final bool plausible =
          RegExp(r'^[A-Za-z0-9가-힣()\-\s]{2,40}\$').hasMatch(line) ||
          RegExp(r'^[A-Za-z0-9가-힣()\-\s]{2,40}').hasMatch(line);
      if (plausible) found.add(line);
    }
    return found.take(10).toList();
  }

  void dispose() {
    _recognizer.close();
  }
}

final ocrService = OcrService();
