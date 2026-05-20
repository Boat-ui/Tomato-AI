import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';

class HistoryPage extends StatefulWidget {
  final List<ScanHistory> history;
  final VoidCallback onChanged;

  const HistoryPage({super.key, required this.history, required this.onChanged});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<ScanHistory> historyList;

  static const _primary = Color(0xFF00C853);
  static const _card = Color(0xFF222222);

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
    historyList = List.from(widget.history);
  }

  @override
  void didUpdateWidget(HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history != widget.history) {
      setState(() => historyList = List.from(widget.history));
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "history",
      jsonEncode(historyList.map((e) => e.toJson()).toList()),
    );
  }

  void _deleteItem(int index) async {
    setState(() => historyList.removeAt(index));
    await _saveHistory();
    widget.onChanged();
  }

  void _deleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Clear History",
            style: TextStyle(color: Colors.white)),
        content: const Text(
            "Are you sure you want to delete all scan history?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => historyList.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("history");
    widget.onChanged();
  }

  Map<String, int> _getStats() {
    final stats = <String, int>{};
    for (final item in historyList) {
      stats[item.disease] = (stats[item.disease] ?? 0) + 1;
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (historyList.isNotEmpty) _buildStats(),
            Expanded(
              child: historyList.isEmpty ? _buildEmpty() : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Text(
            "Scan History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (historyList.isNotEmpty) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${historyList.length} scans",
                style: const TextStyle(color: _primary, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.red),
              onPressed: _deleteAll,
              tooltip: "Clear all",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = _getStats();
    final mostCommon = stats.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: "Total Scans",
              value: "${historyList.length}",
              icon: Icons.document_scanner_rounded,
              color: _primary,
            ),
          ),
          Container(
              width: 1, height: 40, color: const Color(0xFF2A2A2A)),
          Expanded(
            child: _StatItem(
              label: "Most Common",
              value: mostCommon.key.split(" ").first,
              icon: Icons.bar_chart_rounded,
              color: diseaseColors[mostCommon.key] ?? _primary,
            ),
          ),
          Container(
              width: 1, height: 40, color: const Color(0xFF2A2A2A)),
          Expanded(
            child: _StatItem(
              label: "Healthy",
              value: "${stats['Healthy'] ?? 0}",
              icon: Icons.eco_rounded,
              color: const Color(0xFF00C853),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: historyList.length,
      itemBuilder: (context, index) {
        final item = historyList[index];
        final color = diseaseColors[item.disease] ?? _primary;

        return Dismissible(
          key: Key(item.imagePath + item.date),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.red),
          ),
          onDismissed: (_) => _deleteItem(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: File(item.imagePath).existsSync()
                    ? Image.file(
                        File(item.imagePath),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFF2A2A2A),
                        child: const Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.grey),
                      ),
              ),
              title: Text(
                item.disease,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    item.date,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.disease == "Healthy" ? "✓" : "!",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 70, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text("No scans yet",
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Your scan history will appear here",
              style: TextStyle(
                  color: Colors.grey.shade700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(label,
            style:
                const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}