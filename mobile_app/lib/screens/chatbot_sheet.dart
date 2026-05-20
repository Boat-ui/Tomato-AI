import 'package:flutter/material.dart';

class ChatBotSheet extends StatefulWidget {
  const ChatBotSheet({super.key});

  @override
  State<ChatBotSheet> createState() => _ChatBotSheetState();
}

class _ChatBotSheetState extends State<ChatBotSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _primary = Color(0xFF00C853);
  static const _card = Color(0xFF222222);
  static const _surface = Color(0xFF1A1A1A);

  final List<Map<String, String>> _messages = [];

  String _getResponse(String input) {
    final q = input.toLowerCase();

    // Greetings
    if (q.contains("hello") || q.contains("hi") || q.contains("hey")) {
      return "Hello! 👋 I'm your Tomato AI Assistant. Ask me about any tomato disease, treatment, or prevention tips!";
    }

    // Bacterial Spot
    if (q.contains("bacterial spot") || q.contains("bacterial")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🟠 Bacterial Spot Treatment:\n• Apply copper-based bactericides every 7–10 days\n• Avoid overhead irrigation\n• Remove and destroy infected leaves\n• Disinfect tools between plants\n• Use disease-free seeds";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🟠 Bacterial Spot Prevention:\n• Use certified disease-free seeds\n• Avoid working with plants when wet\n• Practice crop rotation\n• Space plants for good airflow\n• Apply preventive copper sprays";
      }
      return "🟠 Bacterial Spot is caused by Xanthomonas bacteria. It appears as small, dark, water-soaked spots on leaves that turn brown with yellow halos. It spreads in warm, wet conditions. Ask me about treatment or prevention!";
    }

    // Early Blight
    if (q.contains("early blight")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🟡 Early Blight Treatment:\n• Remove infected lower leaves immediately\n• Apply chlorothalonil or mancozeb fungicide\n• Spray every 7–10 days in wet weather\n• Ensure proper plant spacing\n• Avoid wetting foliage when watering";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🟡 Early Blight Prevention:\n• Rotate crops every 2–3 years\n• Mulch around plants\n• Water at the base, not overhead\n• Remove plant debris after harvest\n• Use resistant tomato varieties";
      }
      return "🟡 Early Blight is a fungal disease caused by Alternaria solani. It creates dark brown spots with concentric rings (like a target) on older leaves first. Ask me about treatment or prevention!";
    }

    // Late Blight
    if (q.contains("late blight")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🔴 Late Blight Treatment:\n• Apply Mancozeb or copper fungicide IMMEDIATELY\n• Remove and destroy all infected plants\n• Do not compost infected material\n• Spray remaining plants preventively\n• Avoid overhead watering";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🔴 Late Blight Prevention:\n• Plant resistant varieties\n• Ensure good drainage and airflow\n• Apply preventive fungicides in humid weather\n• Remove volunteer tomato plants\n• Monitor plants daily in cool, wet weather";
      }
      return "🔴 Late Blight is a devastating disease caused by Phytophthora infestans. It creates large, dark, water-soaked lesions and can destroy a crop in days. It thrives in cool, wet conditions. This is a HIGH SEVERITY disease — act fast!";
    }

    // Leaf Mold
    if (q.contains("leaf mold") || q.contains("mold")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🟢 Leaf Mold Treatment:\n• Improve greenhouse ventilation\n• Apply chlorothalonil fungicide\n• Reduce humidity below 85%\n• Remove severely infected leaves\n• Space plants further apart";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🟢 Leaf Mold Prevention:\n• Maintain good air circulation\n• Avoid overhead watering\n• Keep humidity low in greenhouses\n• Use resistant tomato varieties\n• Apply preventive fungicide sprays";
      }
      return "🟢 Leaf Mold is caused by the fungus Passalora fulva. It shows as pale green or yellow spots on upper leaf surfaces with olive-green mold underneath. It mainly affects greenhouse tomatoes in high humidity.";
    }

    // Mosaic Virus
    if (q.contains("mosaic") || q.contains("mosaic virus")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🔵 Mosaic Virus Treatment:\n• Remove and destroy infected plants immediately\n• There is NO cure for infected plants\n• Control aphid populations with insecticide\n• Disinfect all tools with bleach solution\n• Wash hands before handling plants";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🔵 Mosaic Virus Prevention:\n• Use virus-resistant seed varieties\n• Control aphids and other insect vectors\n• Remove weeds near tomato plants\n• Avoid using tobacco near plants\n• Disinfect tools regularly";
      }
      return "🔵 Tomato Mosaic Virus causes mottled light and dark green patterns on leaves, leaf distortion, and stunted growth. It spreads through contact, tools, and insect vectors. There is no cure — prevention is key!";
    }

    // Septoria Leaf Spot
    if (q.contains("septoria")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🟣 Septoria Leaf Spot Treatment:\n• Remove affected leaves immediately\n• Apply copper or chlorothalonil fungicide\n• Spray every 7–10 days\n• Avoid wetting foliage\n• Destroy removed plant material";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🟣 Septoria Leaf Spot Prevention:\n• Rotate crops yearly\n• Mulch to prevent soil splash\n• Remove plant debris after harvest\n• Water at base of plants\n• Use resistant varieties when available";
      }
      return "🟣 Septoria Leaf Spot is caused by the fungus Septoria lycopersici. It appears as small, circular spots with dark borders and light centers, usually starting on lower leaves. It spreads rapidly in wet weather.";
    }

    // Target Spot
    if (q.contains("target spot") || q.contains("target")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🔴 Target Spot Treatment:\n• Apply fungicides like azoxystrobin or chlorothalonil\n• Remove infected leaves and debris\n• Improve air circulation around plants\n• Avoid overhead irrigation\n• Repeat spray every 7–14 days";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🔴 Target Spot Prevention:\n• Practice crop rotation\n• Remove plant debris thoroughly\n• Ensure good spacing between plants\n• Apply preventive fungicides\n• Avoid working in wet fields";
      }
      return "🔴 Target Spot is caused by the fungus Corynespora cassiicola. It creates circular brown lesions with concentric rings on leaves, stems, and fruit. It thrives in warm, humid conditions.";
    }

    // Yellow Leaf Curl Virus
    if (q.contains("yellow leaf curl") || q.contains("curl") || q.contains("whitefly") || q.contains("white fly")) {
      if (q.contains("treat") || q.contains("cure") || q.contains("fix")) {
        return "🟡 Yellow Leaf Curl Virus Treatment:\n• Remove and destroy infected plants\n• Apply insecticides to control whiteflies\n• Use reflective mulches to repel whiteflies\n• There is NO cure for infected plants\n• Protect healthy plants with insect screens";
      }
      if (q.contains("prevent") || q.contains("avoid")) {
        return "🟡 Yellow Leaf Curl Prevention:\n• Use virus-resistant tomato varieties\n• Control whitefly populations early\n• Install yellow sticky traps\n• Use insect-proof screens in greenhouses\n• Remove infected plants immediately";
      }
      return "🟡 Tomato Yellow Leaf Curl Virus causes upward curling and yellowing of leaves, stunted growth, and reduced yield. It is spread by whiteflies and has NO cure. Control whiteflies to prevent spread!";
    }

    // Healthy
    if (q.contains("healthy") || q.contains("health") || q.contains("care") || q.contains("maintain")) {
      return "✅ Healthy Tomato Plant Care:\n• Water deeply 2–3 times per week\n• Fertilize every 2 weeks with balanced fertilizer\n• Prune suckers for better airflow\n• Check regularly for early signs of disease\n• Stake or cage plants for support\n• Mulch to retain moisture and prevent soil splash";
    }

    // Fungicide
    if (q.contains("fungicide") || q.contains("fungal")) {
      return "🍄 Common Fungicides for Tomatoes:\n• Mancozeb — broad spectrum, great for late/early blight\n• Chlorothalonil — effective for most fungal diseases\n• Copper-based sprays — works for bacteria and fungi\n• Azoxystrobin — systemic, long-lasting protection\n\nAlways follow label instructions and rotate fungicides to prevent resistance.";
    }

    // Watering
    if (q.contains("water") || q.contains("irrigat")) {
      return "💧 Watering Tips for Tomatoes:\n• Water deeply at the base, not overhead\n• Water early in the morning\n• Keep soil consistently moist but not waterlogged\n• Use drip irrigation when possible\n• Inconsistent watering causes blossom end rot";
    }

    // Fertilizer
    if (q.contains("fertiliz") || q.contains("nutrient") || q.contains("feed")) {
      return "🌱 Fertilizing Tomatoes:\n• Use balanced NPK fertilizer (10-10-10) early on\n• Switch to low-nitrogen, high-phosphorus when flowering\n• Calcium prevents blossom end rot\n• Fertilize every 2 weeks during growing season\n• Avoid over-fertilizing with nitrogen — causes leafy growth, less fruit";
    }

    // Pest
    if (q.contains("pest") || q.contains("insect") || q.contains("bug") || q.contains("aphid") || q.contains("spider mite")) {
      return "🐛 Common Tomato Pests:\n• Aphids — use neem oil or insecticidal soap\n• Spider Mites — increase humidity, use miticide\n• Whiteflies — yellow sticky traps, insecticide\n• Hornworms — pick by hand or use Bt spray\n• Thrips — use spinosad or neem oil\n\nCheck undersides of leaves regularly!";
    }

    // General disease question
    if (q.contains("disease") || q.contains("sick") || q.contains("problem") || q.contains("wrong")) {
      return "🍅 I can help with these tomato diseases:\n\n• Bacterial Spot\n• Early Blight\n• Late Blight\n• Leaf Mold\n• Mosaic Virus\n• Septoria Leaf Spot\n• Target Spot\n• Yellow Leaf Curl Virus\n\nJust ask me about any of them — I can explain symptoms, treatments, and prevention!";
    }

    // Thanks
    if (q.contains("thank") || q.contains("thanks") || q.contains("appreciate")) {
      return "You're welcome! 🌿 Feel free to ask anything else about your tomato plants. Happy farming!";
    }

    // Default
    return "🤔 I'm not sure about that. I specialize in tomato plant diseases and care. Try asking about:\n\n• A specific disease (e.g. 'What is late blight?')\n• Treatment (e.g. 'How to treat mosaic virus?')\n• Prevention (e.g. 'How to prevent early blight?')\n• General care (e.g. 'How to water tomatoes?')";
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    final response = _getResponse(text);

    setState(() {
      _messages.add({"role": "user", "content": text});
      _messages.add({"role": "assistant", "content": response});
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          Expanded(child: _buildMessages()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: _primary, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tomato AI Assistant",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text("Offline — Always Available",
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const Spacer(),
          if (_messages.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _messages.clear()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Clear",
                    style:
                        TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) return _buildWelcome();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildBubble(msg["role"]!, msg["content"]!);
      },
    );
  }

  Widget _buildWelcome() {
    final suggestions = [
      "How do I treat late blight?",
      "What is mosaic virus?",
      "How to prevent early blight?",
      "How to water tomatoes properly?",
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primary.withOpacity(0.2)),
            ),
            child: const Column(
              children: [
                Text("🌿", style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text(
                  "Hi! I'm your Tomato AI Assistant",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  "Ask me anything about tomato diseases, treatments, or plant care. Works offline!",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Suggested questions",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          ...suggestions.map((s) => GestureDetector(
                onTap: () {
                  _controller.text = s;
                  _sendMessage();
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          color: _primary, size: 16),
                      const SizedBox(width: 10),
                      Text(s,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBubble(String role, String content) {
    final isUser = role == "user";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: _primary, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _primary : _card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                content,
                style: TextStyle(
                  color: isUser ? Colors.black : Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style:
                  const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Ask about tomato diseases...",
                hintStyle: const TextStyle(
                    color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: _card,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}