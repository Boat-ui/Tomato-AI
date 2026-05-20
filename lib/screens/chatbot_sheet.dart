import 'package:flutter/material.dart';

class ChatBotSheet extends StatefulWidget {
  const ChatBotSheet({super.key});

  @override
  State<ChatBotSheet> createState() => _ChatBotSheetState();
}

class _ChatBotSheetState extends State<ChatBotSheet> {
  final TextEditingController controller = TextEditingController();
  String response = "";

  String getResponse(String q) {
    q = q.toLowerCase();

    if (q.contains("late blight")) {
      return "Late blight is caused by fungi in wet conditions. Use fungicides like Mancozeb.";
    } else if (q.contains("early blight")) {
      return "Early blight is a fungal disease. Improve airflow and remove infected leaves.";
    } else if (q.contains("prevent")) {
      return "Avoid overwatering and ensure proper spacing between plants.";
    } else if (q.contains("yellow leaf curl")) {
      return "It is caused by a virus spread by whiteflies. Control insects.";
    } else {
      return "Ask about tomato diseases, treatment, or prevention.";
    }
  }

  void ask() {
    setState(() {
      response = getResponse(controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 350,
        child: Column(
          children: [
            const Text(
              "🤖 AI Assistant",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Ask about diseases...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: ask,
              child: const Text("Ask"),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Text(response),
              ),
            ),
          ],
        ),
      ),
    );
  }
}