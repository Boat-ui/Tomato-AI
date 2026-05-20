// Simple translation system — no flutter_gen needed
class AppTranslations {
  static String _lang = 'en';

  static void setLanguage(String lang) {
    _lang = lang;
  }

  static String get currentLang => _lang;

  static bool get isTwi => _lang == 'tw';

  static String get appTitle => isTwi ? "Tomato AI" : "Tomato AI";

  static String get scanLeaf => isTwi
      ? "Fa tomato nhahan bi bra na yɛnhwɛ yadeɛ"
      : "Scan a tomato leaf to detect disease";

  static String get camera => isTwi ? "Kamera" : "Camera";

  static String get gallery => isTwi ? "Foto" : "Gallery";

  static String get analyzing => isTwi ? "Yɛhwɛ mu..." : "Analyzing...";

  static String get noImage => isTwi ? "Foto nni hɔ" : "No image selected";

  static String get diseaseDetected =>
      isTwi ? "Yadeɛ Ahyia" : "Disease Detected";

  static String get healthyPlant =>
      isTwi ? "Atɔre Ye Ateɛ" : "Healthy Plant";

  static String get watchVideo => isTwi ? "Hwɛ Video" : "Watch Video";

  static String get saveReport => isTwi ? "Siw Nhoma" : "Save Report";

  static String get saved => isTwi ? "Asiw" : "Saved";

  static String get notTomatoLeaf => isTwi
      ? "Eyi nyɛ tomato nhahan anaa foto no nhyia"
      : "Not a tomato leaf or unclear image";

  static String get modelReady => isTwi ? "Ɛdii adeɛ" : "Ready";

  static String get modelLoading => isTwi ? "Ɛreload..." : "Loading...";

  static String get scanHistory =>
      isTwi ? "Scan Nhoma" : "Scan History";

  static String get noHistory =>
      isTwi ? "Scan biara nni hɔ" : "No scans yet";

  static String get totalScans => isTwi ? "Scan Nyinaa" : "Total Scans";

  static String get mostCommon =>
      isTwi ? "Deɛ Ɛba Pii" : "Most Common";

  static String get healthy => isTwi ? "Ye Ateɛ" : "Healthy";

  static String get clearHistory =>
      isTwi ? "Yi Nhoma Nyinaa" : "Clear History";

  static String get clearConfirm => isTwi
      ? "Wopɛ sɛ wudi scan nhoma nyinaa adi?"
      : "Are you sure you want to delete all scan history?";

  static String get cancel => isTwi ? "Gyae" : "Cancel";

  static String get deleteAll => isTwi ? "Yi Nyinaa" : "Delete All";

  static String get treatmentVideos =>
      isTwi ? "Aduro Video" : "Treatment Videos";

  static String get searchDisease =>
      isTwi ? "Hwehwɛ yadeɛ..." : "Search disease...";

  static String get watchYoutube =>
      isTwi ? "Hwɛ YouTube so" : "Watch on YouTube";

  static String get weatherRisk =>
      isTwi ? "Ɔjea ne Yadeɛ Kɔkɔbɔ" : "Weather & Disease Risk";

  static String get pullRefresh =>
      isTwi ? "Twe fam na wɔsesa" : "Pull down to refresh";

  static String get diseaseRisk =>
      isTwi ? "Yadeɛ Kɔkɔbɔ Nhwɛsoɔ" : "Disease Risk Assessment";

  static String get basedOnWeather => isTwi
      ? "Ɛda ɔjea teɛteɛ so"
      : "Based on current weather conditions";

  static String get humidity => isTwi ? "Nsusuiɛ" : "Humidity";

  static String get wind => isTwi ? "Mframa" : "Wind";

  static String get pressure => isTwi ? "Tumi" : "Pressure";

  static String get visibility => isTwi ? "Hwɛ Kwan" : "Visibility";

  static String get chatTitle =>
      isTwi ? "Tomato AI Boafoɔ" : "Tomato AI Assistant";

  static String get chatSubtitle =>
      isTwi ? "Offline — Daa Wɔ Hɔ" : "Offline — Always Available";

  static String get chatHint =>
      isTwi ? "Bisɛ tomato yadeɛ ho asɛm..." : "Ask about tomato diseases...";

  static String get suggestedQuestions =>
      isTwi ? "Asɛmhyɛ Nsɛmmisa" : "Suggested questions";

  static String get home => isTwi ? "Fie" : "Home";

  static String get history => isTwi ? "Nhoma" : "History";

  static String get weather => isTwi ? "Ɔjea" : "Weather";

  static String get videos => isTwi ? "Video" : "Videos";

  static String get confidenceScores =>
      isTwi ? "Gyinae Dodo" : "Confidence Scores";

  static String get alreadySaved =>
      isTwi ? "Wɔasiw scan no dedaw" : "Already saved this scan";

  static String get reportSaved =>
      isTwi ? "✅ Wɔasiw nhoma no" : "✅ Report saved to history";

  static String get modelFailed =>
      isTwi ? "⚠️ Model antumi annya" : "⚠️ Model failed to load";

  static String get scanAgain =>
      isTwi ? "Pɛ Kamera anaa Foto bio" : "Tap Camera or Gallery to scan again";

  // Treatments in Twi
  static final Map<String, String> treatmentsTw = {
    "Bacterial Spot":
        "De kopa aduro pira nnansa biako mu. Mma nsu nhwi nhahan so. Yi nhahan a yadeɛ wɔ mu.",
    "Early Blight":
        "Yi nhahan a yadeɛ wɔ mu fitii fam. De fungicide to so. Di hɔ yiye.",
    "Healthy":
        "Wo atɔre ye ateɛ! Tow nsu yiye, di hɔ yiye, na hwɛ yadeɛ nhyiamu dedaw.",
    "Late Blight":
        "De Mancozeb anaa kopa aduro to so ntɛm ara. Yi atɔre a yadeɛ wɔ mu. Mma nhahan nnɔ nsu.",
    "Leaf Mold":
        "Ma mframa ntena mu yiye. De chlorothalonil aduro to so. Ma nsusuiɛ nte 85% ase.",
    "Mosaic Virus":
        "Yi atɔre a yadeɛ wɔ mu ntɛm ara. Sɛe abɔbɔ a ɛde yadeɛ ba no. Hohoro nneɛma.",
    "Septoria Leaf Spot":
        "Yi nhahan a yadeɛ wɔ mu. De kopa anaa chlorothalonil aduro pira. Sesa atɔre baabi afe biako mu.",
    "Target Spot":
        "De fungicide to so na sesa atɔre baabi. Yi nhahan a yadeɛ wɔ mu. Mma nsu nhwi nhahan so.",
    "Yellow Leaf Curl Virus":
        "Sɛe whitefly a ɛde yadeɛ ba no. Yi atɔre a yadeɛ wɔ mu. De atɔre a yadeɛ ntumi mfa no.",
  };
}