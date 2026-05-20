import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';
import '../translations/app_translations.dart';
import '../main.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'video_page.dart';
import 'weather_page.dart';
import 'chatbot_sheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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
      final decoded = jsonDecode(data) as List;
      setState(() {
        history = decoded.map((e) => ScanHistory.fromJson(e)).toList();
      });
    }
  }

  void refreshHistory() => loadHistory();

  Future<void> _toggleLanguage() async {
    final newLang = AppTranslations.isTwi ? 'en' : 'tw';
    AppTranslations.setLanguage(newLang);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLang);

    // Rebuild entire app
    MyApp.of(context)?.rebuild();
    setState(() {});
  }

  void _openChatBot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatBotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNewHistory: refreshHistory),
      HistoryPage(history: history, onChanged: refreshHistory),
      const WeatherPage(),
      const VideoPage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          pages[currentIndex],
          // Language toggle button
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: _toggleLanguage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00C853)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language_rounded,
                        color: Color(0xFF00C853), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      AppTranslations.isTwi ? 'EN' : 'TW',
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00C853),
        elevation: 4,
        onPressed: _openChatBot,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.black),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: AppTranslations.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_rounded),
              label: AppTranslations.history,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.cloud_rounded),
              label: AppTranslations.weather,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.video_library_rounded),
              label: AppTranslations.videos,
            ),
          ],
        ),
      ),
    );
  }
}