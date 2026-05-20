import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/scan_history.dart';
import '../translations/app_translations.dart';

List generateInput(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return [];
  final resized = img.copyResize(image, width: 224, height: 224);
  return List.generate(
    1,
    (_) => List.generate(
      224,
      (y) => List.generate(
        224,
        (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ];
        },
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  final VoidCallback onNewHistory;
  const HomePage({super.key, required this.onNewHistory});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String result = "";
  String treatment = "";
  String detectedDisease = "";
  List<Map<String, dynamic>> topPredictions = [];

  bool isSaved = false;
  bool isLoading = false;
  bool modelLoaded = false;

  Interpreter? interpreter;
  final FlutterTts tts = FlutterTts();

  static const _primary = Color(0xFF00C853);
  static const _card = Color(0xFF222222);

  final List<String> labels = [
    "Bacterial Spot",
    "Early Blight",
    "Healthy",
    "Late Blight",
    "Leaf Mold",
    "Mosaic Virus",
    "Septoria Leaf Spot",
    "Target Spot",
    "Yellow Leaf Curl Virus",
  ];

  final Map<String, String> videoLinks = {
    "Bacterial Spot": "https://www.youtube.com/results?search_query=tomato+bacterial+spot+treatment",
    "Early Blight": "https://www.youtube.com/results?search_query=tomato+early+blight+treatment",
    "Healthy": "https://www.youtube.com/results?search_query=healthy+tomato+plant+care",
    "Late Blight": "https://www.youtube.com/results?search_query=tomato+late+blight+treatment",
    "Leaf Mold": "https://www.youtube.com/results?search_query=tomato+leaf+mold+treatment",
    "Mosaic Virus": "https://www.youtube.com/results?search_query=tomato+mosaic+virus+treatment",
    "Septoria Leaf Spot": "https://www.youtube.com/results?search_query=tomato+septoria+leaf+spot+treatment",
    "Target Spot": "https://www.youtube.com/results?search_query=tomato+target+spot+treatment",
    "Yellow Leaf Curl Virus": "https://www.youtube.com/results?search_query=tomato+yellow+leaf+curl+virus+treatment",
  };

  final Map<String, String> treatments = {
    "Bacterial Spot": "Apply copper-based bactericides every 7–10 days. Avoid overhead irrigation and remove infected plant debris.",
    "Early Blight": "Remove infected lower leaves. Apply chlorothalonil or mancozeb fungicide. Ensure proper plant spacing.",
    "Healthy": "Your plant looks healthy! Continue regular watering, proper spacing, and monitor for early signs of disease.",
    "Late Blight": "Apply Mancozeb or copper fungicide immediately. Remove and destroy infected plants. Avoid wet foliage.",
    "Leaf Mold": "Improve greenhouse ventilation. Apply fungicides like chlorothalonil. Reduce humidity below 85%.",
    "Mosaic Virus": "Remove infected plants immediately. Control aphids with insecticide. Disinfect tools. Use virus-resistant seeds.",
    "Septoria Leaf Spot": "Remove affected leaves. Spray with fungicide containing copper or chlorothalonil. Rotate crops yearly.",
    "Target Spot": "Apply fungicides and practice crop rotation. Remove infected debris. Avoid overhead watering.",
    "Yellow Leaf Curl Virus": "Control whitefly populations with insecticides. Remove and destroy infected plants. Use resistant varieties.",
  };

  final Map<String, Color> diseaseColors = {
    "Bacterial Spot": const Color(0xFFFF6B35),
    "Early Blight": const Color(0xFFFFB300),
    "Healthy": const Color(0xFF00C853),
    "Late Blight": const Color(0xFFE53935),
    "Leaf Mold": const Color(0xFF8BC34A),
    "Mosaic Virus": const Color(0xFF26C6DA),
    "Septoria Leaf Spot": const Color(0xFFAB47BC),
    "Target Spot": const Color(0xFFEF5350),
    "Yellow Leaf Curl Virus": const Color(0xFFFFEE58),
  };

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initTts();
  }

  @override
  void dispose() {
    interpreter?.close();
    tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);
  }

  Future<void> _loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/tomato_model.tflite');
      setState(() => modelLoaded = true);
      debugPrint("✅ Model loaded successfully");
    } catch (e) {
      debugPrint("❌ MODEL LOAD ERROR: $e");
      setState(() => result = AppTranslations.modelFailed);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!modelLoaded || interpreter == null) {
      _showSnack("Model is still loading, please wait...");
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      result = "";
      treatment = "";
      detectedDisease = "";
      topPredictions = [];
      isSaved = false;
      isLoading = true;
    });
    await _runModel(File(picked.path));
  }

  Future<void> _runModel(File imageFile) async {
    if (interpreter == null) return;
    try {
      final bytes = await imageFile.readAsBytes();
      final input = await compute(generateInput, bytes);
      if (input.isEmpty) {
        setState(() {
          result = "Could not read image";
          isLoading = false;
        });
        return;
      }
      final output = List.generate(1, (_) => List.filled(9, 0.0));
      interpreter!.run(input, output);
      final probs = List<double>.from(output[0]);
      final indexed = probs.asMap().entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top3 = indexed.take(3).map((e) => {
            "label": labels[e.key],
            "confidence": e.value,
          }).toList();
      final top1 = indexed[0].value;
      final top2 = indexed[1].value;
      final disease = labels[indexed[0].key];

      if (top1 < 0.85 || (top1 - top2) < 0.25) {
        setState(() {
          result = "⚠️";
          treatment = "";
          detectedDisease = "";
          topPredictions = [];
          isLoading = false;
        });
        return;
      }

      // Get treatment based on language
      final treatmentText = AppTranslations.isTwi
          ? (AppTranslations.treatmentsTw[disease] ?? treatments[disease] ?? "")
          : (treatments[disease] ?? "");

      setState(() {
        detectedDisease = disease;
        result = disease;
        treatment = treatmentText;
        topPredictions = top3;
        isLoading = false;
      });

      await tts.speak("$disease detected. ${treatments[disease]}");
    } catch (e) {
      debugPrint("❌ RUN ERROR: $e");
      setState(() {
        result = "Error analyzing image";
        isLoading = false;
      });
    }
  }

  Future<void> _saveReport() async {
    if (_image == null || detectedDisease.isEmpty) return;
    if (isSaved) {
      _showSnack(AppTranslations.alreadySaved);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    List<ScanHistory> history = [];
    final data = prefs.getString("history");
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      history = decoded.map((e) => ScanHistory.fromJson(e)).toList();
    }
    history.insert(0, ScanHistory(
      imagePath: _image!.path,
      disease: detectedDisease,
      date: DateTime.now().toString().substring(0, 16),
    ));
    await prefs.setString(
      "history",
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
    setState(() => isSaved = true);
    widget.onNewHistory();
    _showSnack(AppTranslations.reportSaved);
  }

  Future<void> _openVideo() async {
    final url = videoLinks[detectedDisease];
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildScanButtons(),
              const SizedBox(height: 20),
              _buildImageArea(),
              const SizedBox(height: 20),
              if (!isLoading && detectedDisease.isNotEmpty) ...[
                _buildResultCard(),
                const SizedBox(height: 16),
                _buildTopPredictions(),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ] else if (!isLoading && _image != null && result.contains("⚠️")) ...[
                _buildWarningCard(),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D1A), Color(0xFF00C853)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("🍅", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tomato AI",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Disease Detection System",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: modelLoaded
                      ? Colors.black26
                      : Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: modelLoaded ? Colors.greenAccent : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      modelLoaded
                          ? AppTranslations.modelReady
                          : AppTranslations.modelLoading,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppTranslations.scanLeaf,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.camera_alt_rounded,
            label: AppTranslations.camera,
            onPressed: isLoading ? null : () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.photo_library_rounded,
            label: AppTranslations.gallery,
            onPressed: isLoading ? null : () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: _primary),
                    const SizedBox(height: 12),
                    Text(AppTranslations.analyzing,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : _image != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_image!, fit: BoxFit.cover),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            AppTranslations.scanAgain,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco_rounded,
                          size: 60, color: Colors.grey.shade700),
                      const SizedBox(height: 10),
                      Text(AppTranslations.noImage,
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildResultCard() {
    final color = diseaseColors[detectedDisease] ?? _primary;
    final isHealthy = detectedDisease == "Healthy";
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHealthy ? Icons.check_circle : Icons.warning_rounded,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  isHealthy
                      ? AppTranslations.healthyPlant
                      : AppTranslations.diseaseDetected,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            detectedDisease,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.medical_services_rounded, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  treatment,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPredictions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.confidenceScores,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...topPredictions.map((p) {
            final label = p["label"] as String;
            final conf = p["confidence"] as double;
            final color = diseaseColors[label] ?? _primary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      Text(
                        "${(conf * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: conf,
                      backgroundColor: const Color(0xFF2A2A2A),
                      color: color,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppTranslations.notTomatoLeaf,
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openVideo,
            icon: const Icon(Icons.play_circle_outline_rounded,
                color: _primary, size: 18),
            label: Text(AppTranslations.watchVideo,
                style: const TextStyle(color: _primary, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveReport,
            icon: Icon(
              isSaved ? Icons.check_rounded : Icons.bookmark_add_rounded,
              size: 18,
            ),
            label: Text(
                isSaved ? AppTranslations.saved : AppTranslations.saveReport,
                style: const TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSaved ? const Color(0xFF2A2A2A) : _primary,
              foregroundColor: isSaved ? Colors.grey : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF222222),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00C853), size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}