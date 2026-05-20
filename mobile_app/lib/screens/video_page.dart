import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  String search = "";

  static const _primary = Color(0xFF00C853);
  static const _card = Color(0xFF222222);

  final List<Map<String, dynamic>> videos = [
    {
      "title": "Bacterial Spot",
      "subtitle": "Bacterial — Medium severity",
      "url": "https://www.youtube.com/results?search_query=tomato+bacterial+spot+treatment",
      "image": "assets/images/bacterial.jpg",
      "color": const Color(0xFFFF6B35),
      "icon": Icons.coronavirus_rounded,
    },
    {
      "title": "Early Blight",
      "subtitle": "Fungal — Medium severity",
      "url": "https://www.youtube.com/results?search_query=tomato+early+blight+treatment",
      "image": "assets/images/early_blight.jpg",
      "color": const Color(0xFFFFB300),
      "icon": Icons.warning_amber_rounded,
    },
    {
      "title": "Healthy Plant Care",
      "subtitle": "Maintenance tips",
      "url": "https://www.youtube.com/results?search_query=healthy+tomato+plant+care",
      "image": "assets/images/leaf_mold.jpg",
      "color": _primary,
      "icon": Icons.spa_rounded,
    },
    {
      "title": "Late Blight",
      "subtitle": "Fungal — High severity",
      "url": "https://www.youtube.com/results?search_query=tomato+late+blight+treatment",
      "image": "assets/images/late_blight.jpg",
      "color": const Color(0xFFE53935),
      "icon": Icons.warning_rounded,
    },
    {
      "title": "Leaf Mold",
      "subtitle": "Fungal — Low severity",
      "url": "https://www.youtube.com/results?search_query=tomato+leaf+mold+treatment",
      "image": "assets/images/leaf_mold.jpg",
      "color": const Color(0xFF8BC34A),
      "icon": Icons.eco_rounded,
    },
    {
      "title": "Mosaic Virus",
      "subtitle": "Viral — High severity",
      "url": "https://www.youtube.com/results?search_query=tomato+mosaic+virus+treatment",
      "image": "assets/images/bacterial.jpg",
      "color": const Color(0xFF26C6DA),
      "icon": Icons.bug_report_rounded,
    },
    {
      "title": "Septoria Leaf Spot",
      "subtitle": "Fungal — Medium severity",
      "url": "https://www.youtube.com/results?search_query=tomato+septoria+leaf+spot+treatment",
      "image": "assets/images/septoria.jpg",
      "color": const Color(0xFFAB47BC),
      "icon": Icons.blur_circular_rounded,
    },
    {
      "title": "Target Spot",
      "subtitle": "Fungal — Medium severity",
      "url": "https://www.youtube.com/results?search_query=tomato+target+spot+treatment",
      "image": "assets/images/late_blight.jpg",
      "color": const Color(0xFFEF5350),
      "icon": Icons.adjust_rounded,
    },
    {
      "title": "Yellow Leaf Curl Virus",
      "subtitle": "Viral — High severity",
      "url": "https://www.youtube.com/results?search_query=tomato+yellow+leaf+curl+virus+treatment",
      "image": "assets/images/yellow_leaf.jpg",
      "color": const Color(0xFFFFEE58),
      "icon": Icons.pest_control_rounded,
    },
  ];

  Future<void> _openLink(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = videos
        .where((v) => (v["title"] as String)
            .toLowerCase()
            .contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearch(),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _buildVideoCard(filtered[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Treatment Videos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Watch tutorials for each disease",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (val) => setState(() => search = val),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search disease...",
          prefixIcon:
              const Icon(Icons.search_rounded, color: Colors.grey),
          suffixIcon: search.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: Colors.grey),
                  onPressed: () => setState(() => search = ""),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final color = video["color"] as Color;

    return GestureDetector(
      onTap: () => _openLink(video["url"] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    video["image"] as String,
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 80,
                      color: color.withOpacity(0.15),
                      child: Icon(video["icon"] as IconData,
                          color: color, size: 30),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Icon(
                          Icons.play_circle_filled_rounded,
                          color: Colors.white54,
                          size: 28),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video["title"] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video["subtitle"] as String,
                      style: TextStyle(color: color, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.youtube_searched_for_rounded,
                            color: Colors.red, size: 13),
                        SizedBox(width: 4),
                        Text("Watch on YouTube",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade700, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 60, color: Colors.grey.shade700),
          const SizedBox(height: 12),
          Text('No results for "$search"',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}