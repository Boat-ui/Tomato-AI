import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';

class HistoryPage extends StatefulWidget {
  final List<ScanHistory> history;
  final VoidCallback onChanged;

  const HistoryPage({
    super.key,
    required this.history,
    required this.onChanged,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<ScanHistory> historyList;

  @override
  void initState() {
    super.initState();
    historyList = widget.history;
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "history",
        jsonEncode(historyList.map((e) => e.toJson()).toList()));
  }

  void deleteItem(int index) async {
    setState(() {
      historyList.removeAt(index);
    });
    await saveHistory();
    widget.onChanged();
  }

  void deleteAll() async {
    setState(() {
      historyList.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.remove("history");

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: deleteAll,
          )
        ],
      ),
      body: historyList.isEmpty
          ? const Center(child: Text("No history"))
          : ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.file(File(item.imagePath), width: 50),
                    title: Text(item.disease),
                    subtitle: Text(item.date),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteItem(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}