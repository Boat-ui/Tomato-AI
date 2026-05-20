import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scan_history.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback onNewHistory;

  const HomePage({
    super.key,
    required this.toggleTheme,
    required this.onNewHistory,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String result = "Upload a tomato leaf image";
  String treatment = "";
  String detectedDisease = "";

  /// 🔥 NEW FLAG
  bool isSaved = false;

  late Interpreter interpreter;
  final FlutterTts tts = FlutterTts();

  final Map<String, String> videoLinks = {
    "Late Blight":
        "https://www.youtube.com/results?search_query=tomato+late+blight+treatment",
    "Early Blight":
        "https://www.youtube.com/results?search_query=tomato+early+blight+treatment",
    "Bacterial Spot":
        "https://www.youtube.com/results?search_query=tomato+bacterial+spot+treatment",
    "Leaf Mold":
        "https://www.youtube.com/results?search_query=tomato+leaf+mold+treatment",
    "Septoria Leaf Spot":
        "https://www.youtube.com/results?search_query=tomato+septoria+leaf+spot+treatment",
    "Yellow Leaf Curl Virus":
        "https://www.youtube.com/results?search_query=tomato+yellow+leaf+curl+virus+treatment",
    "Target Spot":
        "https://www.youtube.com/results?search_query=tomato+target+spot+treatment",
    "Spider Mites":
        "https://www.youtube.com/results?search_query=tomato+spider+mites+treatment",
    "Healthy":
        "https://www.youtube.com/results?search_query=healthy+tomato+plant+care",
  };

  final List<String> labels = [
    "Bacterial Spot",
    "Early Blight",
    "Late Blight",
    "Leaf Mold",
    "Septoria Leaf Spot",
    "Spider Mites",
    "Target Spot",
    "Yellow Leaf Curl Virus",
    "Healthy"
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/tomato_model.tflite');
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      result = "Analyzing...";
      treatment = "";
      detectedDisease = "";
      isSaved = false; /// 🔥 RESET SAVE STATE
    });

    runModel(File(picked.path));
  }

  void runModel(File imageFile) async {
    var bytes = await imageFile.readAsBytes();
    img.Image? oriImage = img.decodeImage(bytes);
    if (oriImage == null) return;

    img.Image resized = img.copyResize(oriImage, width: 160, height: 160);

    var input = List.generate(
      1,
      (_) => List.generate(
        160,
        (y) => List.generate(
          160,
          (x) {
            var pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    var output = List.generate(1, (_) => List.filled(9, 0.0));

    interpreter.run(input, output);

    List<double> probs = List.from(output[0]);
    List<double> sorted = List.from(probs)..sort((a, b) => b.compareTo(a));

    double top1 = sorted[0];
    double top2 = sorted[1];

    int index = probs.indexOf(top1);

    String disease = labels[index];

    if (top1 < 0.85 || (top1 - top2) < 0.25) {
      setState(() {
        result = "⚠️ Not a tomato leaf";
        treatment = "";
      });
      return;
    }

    String treatmentText = getTreatment(disease);

    setState(() {
      detectedDisease = disease;
      result =
          "🌿 $disease\nConfidence: ${(top1 * 100).toStringAsFixed(2)}%";
      treatment = treatmentText;
    });

    speakResult(disease, treatmentText);
  }

  Future<void> speakResult(String disease, String treatment) async {
    await tts.speak("$disease detected. $treatment");
  }

  String getTreatment(String disease) {
    return {
      "Bacterial Spot": "Use copper sprays.",
      "Early Blight": "Remove infected leaves and apply fungicide.",
      "Late Blight": "Use Mancozeb immediately.",
      "Leaf Mold": "Improve airflow.",
      "Septoria Leaf Spot": "Remove leaves and spray fungicide.",
      "Spider Mites": "Use neem oil.",
      "Target Spot": "Apply fungicides.",
      "Yellow Leaf Curl Virus": "Control whiteflies.",
      "Healthy": "Plant is healthy."
    }[disease] ?? "";
  }

  Future<void> openVideo() async {
    final url = videoLinks[detectedDisease];
    if (url == null) return;

    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  /// 🔥 SAVE WITH CHECK
  Future<void> saveReport() async {
    if (_image == null || detectedDisease.isEmpty) return;

    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Already saved this scan")),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/report.txt");

    await file.writeAsString("""
Tomato Disease Report

$result

Treatment:
$treatment
""");

    final prefs = await SharedPreferences.getInstance();

    List<ScanHistory> history = [];

    final data = prefs.getString("history");

    if (data != null) {
      List decoded = jsonDecode(data);
      history = decoded.map((e) => ScanHistory.fromJson(e)).toList();
    }

    history.insert(
      0,
      ScanHistory(
        imagePath: _image!.path,
        disease: detectedDisease,
        date: DateTime.now().toString().substring(0, 16),
      ),
    );

    prefs.setString(
        "history", jsonEncode(history.map((e) => e.toJson()).toList()));

    setState(() {
      isSaved = true; /// 🔥 MARK AS SAVED
    });

    widget.onNewHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🍅 Tomato AI Application"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const Text(
              "Tomato Leaf Disease Detector",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text("Camera"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: _image != null
                    ? Image.file(_image!)
                    : const Text("No image selected"),
              ),
            ),

            const SizedBox(height: 10),

            Text(result, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(treatment, textAlign: TextAlign.center),

            const SizedBox(height: 10),

            if (detectedDisease.isNotEmpty)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: openVideo,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Watch Treatment Video"),
                  ),
                  ElevatedButton.icon(
                    onPressed: saveReport,
                    icon: const Icon(Icons.save),
                    label: Text(isSaved ? "Saved ✔" : "Save Report"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}