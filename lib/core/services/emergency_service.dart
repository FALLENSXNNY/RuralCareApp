import 'dart:convert';
import 'package:flutter/services.dart' as services;
import '../models/first_aid_topic.dart';

class EmergencyService {
  EmergencyService._();
  static final EmergencyService instance = EmergencyService._();

  List<FirstAidTopic>? _cachedTopics;

  /// Loads all first aid topics from bundled asset JSON.
  Future<List<FirstAidTopic>> loadTopics() async {
    if (_cachedTopics != null && _cachedTopics!.isNotEmpty) {
      return _cachedTopics!;
    }

    try {
      final raw = await services.rootBundle
          .loadString('assets/emergency/first_aid_content.json');
      final List<dynamic> list = jsonDecode(raw);
      _cachedTopics = list
          .map((item) => FirstAidTopic.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedTopics!;
    } catch (_) {
      return const [];
    }
  }

  /// Finds a specific first aid topic by identifier.
  Future<FirstAidTopic?> getTopicById(String id) async {
    final topics = await loadTopics();
    try {
      return topics.firstWhere((t) => t.id.toLowerCase() == id.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Searches topics by keyword.
  Future<List<FirstAidTopic>> searchTopics(String query) async {
    final topics = await loadTopics();
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
