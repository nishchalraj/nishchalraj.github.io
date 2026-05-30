import 'package:hive_ce/hive.dart';

enum MoodKind { calm, neutral, anxious, sad, energetic }

extension MoodKindX on MoodKind {
  String get label {
    switch (this) {
      case MoodKind.calm:      return 'Calm';
      case MoodKind.neutral:   return 'Neutral';
      case MoodKind.anxious:   return 'Anxious';
      case MoodKind.sad:       return 'Sad';
      case MoodKind.energetic: return 'Energetic';
    }
  }

  String get emoji {
    switch (this) {
      case MoodKind.calm:      return '🌿';
      case MoodKind.neutral:   return '🌤';
      case MoodKind.anxious:   return '🌊';
      case MoodKind.sad:       return '🌧';
      case MoodKind.energetic: return '⚡';
    }
  }
}

class MoodLog extends HiveObject {
  MoodLog({
    required this.id,
    required this.dayKey,
    required this.mood,
    this.note,
    required this.atMs,
  });

  final String id;
  final String dayKey;
  final MoodKind mood;
  final String? note;
  final int atMs;
}
