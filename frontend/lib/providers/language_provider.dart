import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, urdu, punjabi }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english) {
    _loadSavedLanguage();
  }

  static const _prefsKey = 'selected_language';

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);

    if (saved != null) {
      state = AppLanguage.values.firstWhere(
        (l) => l.name == saved,
        orElse: () => AppLanguage.english,
      );
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.name);
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);