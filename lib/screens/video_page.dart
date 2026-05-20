import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  String search = "";

  final List<Map<String, String>> videos = [
    {
      "title": "Late Blight (Tomato)",
      "url":
          "https://www.youtube.com/results?search_query=tomato+late+blight+treatment",
      "image": "assets/images/late_blight.jpg"
    },
    {
      "title": "Early Blight (Tomato)",
      "url":
          "https://www.youtube.com/results?search_query=tomato+early+blight+treatment",
      "image": "assets/images/early_blight.jpg"
    },
    {
      "title": "Bacterial Spot (Tomato)",
      "url":
          "https://www.youtube.com/results?search_query=tomato+bacterial+spot+treatment",
      "image": "assets/images/bacterial.jpg"
    },
    {
      "title": "Leaf Mold (Tomato)",
      "url":
          "https://www.youtube.com/results?search_query=tomato+leaf+mold+treatment",
      "image": "assets/images/leaf_mold.jpg"
    },
    {
      "title": "Septoria Leaf Spot (Tomato)",
      "url":
          "https://www.youtube.com/results?search_query=tomato+septoria+leaf+spot+treatment",
      "image": "assets/images/septoria.jpg"
    },
    {
      "title": "Yellow Leaf Curl Virus (Tomato)",
      "url":
          "https://www.youtube.com/results?search_query=tomato+yellow+leaf+curl+virus+treatment",
      "image": "assets/images/yellow_leaf.jpg"
    },
  ];

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = videos
        .where((v) =>
            v["title"]!.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("🎥 Tomato Treatments")),
      body: Column(
        children: [

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search tomato disease...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => search = val),
            ),
          ),

          /// 📺 LIST
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final video = filtered[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(
                      video["image"]!,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(video["title"]!),
                    subtitle: const Text("Tap to watch on YouTube"),
                    onTap: () => openLink(video["url"]!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}