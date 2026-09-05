import 'dart:convert';
import 'package:flutter/services.dart' as services;
import '../models/first_aid_topic.dart';

class EmergencyService {
  EmergencyService._();
  static final EmergencyService instance = EmergencyService._();

  final Map<String, List<FirstAidTopic>> _cachedTopicsByLang = {};

  /// Loads all first aid topics from bundled asset JSON based on language code.
  Future<List<FirstAidTopic>> loadTopics({String languageCode = 'en'}) async {
    final lang = (languageCode == 'hi' || languageCode == 'bn') ? languageCode : 'en';

    if (_cachedTopicsByLang[lang] != null && _cachedTopicsByLang[lang]!.isNotEmpty) {
      return _cachedTopicsByLang[lang]!;
    }

    try {
      final assetPath = lang == 'en'
          ? 'assets/emergency/first_aid_content.json'
          : 'assets/emergency/first_aid_content_$lang.json';

      final raw = await services.rootBundle.loadString(assetPath);
      final List<dynamic> list = jsonDecode(raw);
      final parsed = list
          .map((item) => FirstAidTopic.fromJson(item as Map<String, dynamic>))
          .toList();
      _cachedTopicsByLang[lang] = parsed;
      return parsed;
    } catch (_) {
      // Fallback to English if localized JSON fails to load
      if (lang != 'en') {
        return loadTopics(languageCode: 'en');
      }
      return const [];
    }
  }

  /// Finds a specific first aid topic by identifier in specified language.
  Future<FirstAidTopic?> getTopicById(String id, {String languageCode = 'en'}) async {
    final topics = await loadTopics(languageCode: languageCode);
    try {
      return topics.firstWhere((t) => t.id.toLowerCase() == id.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Searches topics by keyword in specified language.
  Future<List<FirstAidTopic>> searchTopics(String query, {String languageCode = 'en'}) async {
    final topics = await loadTopics(languageCode: languageCode);
    if (query.trim().isEmpty) return topics;
    final q = query.toLowerCase().trim();
    return topics.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.steps.any((s) => s.title.toLowerCase().contains(q) || s.body.toLowerCase().contains(q)) ||
          t.dos.any((d) => d.toLowerCase().contains(q)) ||
          t.donts.any((d) => d.toLowerCase().contains(q));
    }).toList();
  }
}
