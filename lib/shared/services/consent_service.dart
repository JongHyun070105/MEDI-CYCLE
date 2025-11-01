import 'package:shared_preferences/shared_preferences.dart';

class ConsentService {
  static const String _keyConsentGiven = 'ai_feedback_consent_given';
  static const String _keyConsentDate = 'ai_feedback_consent_date';

  Future<bool> hasConsentGiven() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConsentGiven) ?? false;
  }

  Future<void> setConsentGiven(bool given) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyConsentGiven, given);
    if (given) {
      await prefs.setString(_keyConsentDate, DateTime.now().toIso8601String());
    } else {
      await prefs.remove(_keyConsentDate);
    }
  }

  Future<DateTime?> getConsentDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyConsentDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
}

final ConsentService consentService = ConsentService();

