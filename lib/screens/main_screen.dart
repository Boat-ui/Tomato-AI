import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'video_page.dart';
import 'chatbot_sheet.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MainScreen({super.key, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  List<ScanHistory> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("history");

    if (data != null) {
      List decoded = jsonDecode(data);
      setState(() {
        history = decoded.map((e) => ScanHistory.fromJson(e)).toList();
      });
    }
  }

  void refreshHistory() => loadHistory();

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(toggleTheme: widget.toggleTheme, onNewHistory: refreshHistory),
      HistoryPage(history: history, onChanged: refreshHistory),
      const VideoPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.smart_toy),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ChatBotSheet(),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: "Videos"),
        ],
      ),
    );
  }
}