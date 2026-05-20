import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // ⚠️ Replace with your OpenWeatherMap API key
  static const _apiKey = "8a02b264971d3d240ff10ba94680f6d2";

  static const _primary = Color(0xFF00C853);
  static const _card = Color(0xFF222222);

  Map<String, dynamic>? _weather;
  bool _isLoading = false;
  String _error = "";
  String _locationName = "";

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = "Location permission denied. Please enable it in settings.";
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Fetch weather from OpenWeatherMap
      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weather = data;
          _locationName = "${data['name']}, ${data['sys']['country']}";
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Could not fetch weather. Check your API key.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDiseaseRisks() {
    if (_weather == null) return [];

    final temp = (_weather!['main']['temp'] as num).toDouble();
    final humidity = (_weather!['main']['humidity'] as num).toDouble();
    final weatherMain = _weather!['weather'][0]['main'].toString().toLowerCase();
    final windSpeed = (_weather!['wind']['speed'] as num).toDouble();

    final risks = <Map<String, dynamic>>[];

    // Late Blight — cool + wet
    if (temp < 24 && humidity > 75) {
      risks.add({
        "disease": "Late Blight",
        "risk": "High Risk",
        "color": const Color(0xFFE53935),
        "icon": Icons.warning_rounded,
        "reason": "Cool temperature (${temp.toStringAsFixed(1)}°C) and high humidity (${humidity.toStringAsFixed(0)}%) are ideal for Late Blight.",
        "action": "Apply Mancozeb fungicide preventively today.",
      });
    }

    // Early Blight — warm + moderate humidity
    if (temp >= 24 && temp <= 29 && humidity > 60) {
      risks.add({
        "disease": "Early Blight",
        "risk": "Moderate Risk",
        "color": const Color(0xFFFFB300),
        "icon": Icons.warning_amber_rounded,
        "reason": "Warm temperature (${temp.toStringAsFixed(1)}°C) with moderate humidity (${humidity.toStringAsFixed(0)}%) favors Early Blight.",
        "action": "Inspect lower leaves. Apply chlorothalonil if spots appear.",
      });
    }

    // Bacterial Spot — warm + wet + windy
    if (temp > 25 && humidity > 70 && weatherMain.contains("rain")) {
      risks.add({
        "disease": "Bacterial Spot",
        "risk": "High Risk",
        "color": const Color(0xFFFF6B35),
        "icon": Icons.coronavirus_rounded,
        "reason": "Rain and warm temperatures (${temp.toStringAsFixed(1)}°C) spread Bacterial Spot rapidly.",
        "action": "Apply copper-based bactericide. Avoid working in the field when wet.",
      });
    }

    // Leaf Mold — high humidity greenhouse
    if (humidity > 85) {
      risks.add({
        "disease": "Leaf Mold",
        "risk": "High Risk",
        "color": const Color(0xFF8BC34A),
        "icon": Icons.eco_rounded,
        "reason": "Very high humidity (${humidity.toStringAsFixed(0)}%) is perfect for Leaf Mold growth.",
        "action": "Improve ventilation immediately. Reduce humidity below 85%.",
      });
    }

    // Septoria Leaf Spot — wet weather
    if (weatherMain.contains("rain") || weatherMain.contains("drizzle")) {
      risks.add({
        "disease": "Septoria Leaf Spot",
        "risk": "Moderate Risk",
        "color": const Color(0xFFAB47BC),
        "icon": Icons.blur_circular_rounded,
        "reason": "Rainy conditions spread Septoria spores through soil splash.",
        "action": "Mulch around plants to prevent soil splash. Spray fungicide.",
      });
    }

    // Yellow Leaf Curl — hot + dry (whitefly weather)
    if (temp > 28 && humidity < 50) {
      risks.add({
        "disease": "Yellow Leaf Curl Virus",
        "risk": "Moderate Risk",
        "color": const Color(0xFFFFEE58),
        "icon": Icons.pest_control_rounded,
        "reason": "Hot, dry weather (${temp.toStringAsFixed(1)}°C) increases whitefly activity which spreads this virus.",
        "action": "Install yellow sticky traps. Apply whitefly insecticide.",
      });
    }

    // All good
    if (risks.isEmpty) {
      risks.add({
        "disease": "All Clear",
        "risk": "Low Risk",
        "color": _primary,
        "icon": Icons.check_circle_rounded,
        "reason": "Current weather conditions are not particularly favorable for tomato diseases.",
        "action": "Continue regular monitoring and preventive care.",
      });
    }

    return risks;
  }

  String _getWeatherIcon(String main) {
    switch (main.toLowerCase()) {
      case "clear":
        return "☀️";
      case "clouds":
        return "☁️";
      case "rain":
        return "🌧️";
      case "drizzle":
        return "🌦️";
      case "thunderstorm":
        return "⛈️";
      case "snow":
        return "❄️";
      case "mist":
      case "fog":
        return "🌫️";
      default:
        return "🌤️";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWeather,
          color: _primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                if (_isLoading)
                  _buildLoading()
                else if (_error.isNotEmpty)
                  _buildError()
                else if (_weather != null) ...[
                  _buildWeatherCard(),
                  const SizedBox(height: 20),
                  _buildConditionsRow(),
                  const SizedBox(height: 20),
                  _buildDiseaseRisks(),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weather & Disease Risk",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Pull down to refresh",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: _fetchWeather,
          icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 16),
            Text("Getting your location...",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_error,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final temp = (_weather!['main']['temp'] as num).toDouble();
    final feelsLike = (_weather!['main']['feels_like'] as num).toDouble();
    final description = _weather!['weather'][0]['description'].toString();
    final main = _weather!['weather'][0]['main'].toString();
    final icon = _getWeatherIcon(main);

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
              const Icon(Icons.location_on_rounded,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                _locationName,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${temp.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description[0].toUpperCase() +
                        description.substring(1),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Feels like ${feelsLike.toStringAsFixed(1)}°C",
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsRow() {
    final humidity = (_weather!['main']['humidity'] as num).toDouble();
    final windSpeed = (_weather!['wind']['speed'] as num).toDouble();
    final pressure = (_weather!['main']['pressure'] as num).toDouble();
    final visibility = _weather!['visibility'] != null
        ? ((_weather!['visibility'] as num) / 1000).toStringAsFixed(1)
        : "N/A";

    return Row(
      children: [
        Expanded(
            child: _ConditionCard(
                icon: Icons.water_drop_rounded,
                label: "Humidity",
                value: "${humidity.toStringAsFixed(0)}%",
                color: const Color(0xFF29B6F6))),
        const SizedBox(width: 10),
        Expanded(
            child: _ConditionCard(
                icon: Icons.air_rounded,
                label: "Wind",
                value: "${windSpeed.toStringAsFixed(1)} m/s",
                color: const Color(0xFF78909C))),
        const SizedBox(width: 10),
        Expanded(
            child: _ConditionCard(
                icon: Icons.compress_rounded,
                label: "Pressure",
                value: "${pressure.toStringAsFixed(0)} hPa",
                color: const Color(0xFFAB47BC))),
        const SizedBox(width: 10),
        Expanded(
            child: _ConditionCard(
                icon: Icons.visibility_rounded,
                label: "Visibility",
                value: "$visibility km",
                color: const Color(0xFF26C6DA))),
      ],
    );
  }

  Widget _buildDiseaseRisks() {
    final risks = _getDiseaseRisks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Disease Risk Assessment",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Based on current weather conditions",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 14),
        ...risks.map((risk) => _buildRiskCard(risk)),
      ],
    );
  }

  Widget _buildRiskCard(Map<String, dynamic> risk) {
    final color = risk["color"] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(risk["icon"] as IconData, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                risk["disease"] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk["risk"] as String,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Colors.grey, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  risk["reason"] as String,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.medical_services_rounded,
                  color: color, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  risk["action"] as String,
                  style: TextStyle(
                      color: color, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ConditionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}