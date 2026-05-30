import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class SoundscapeMeta {
  const SoundscapeMeta({required this.id, required this.label, required this.asset, required this.description});
  final String id;
  final String label;
  final String asset;
  final String description;
}

const kSoundscapes = <SoundscapeMeta>[
  SoundscapeMeta(id: 'forest', label: 'Forest', asset: 'assets/sounds/forest.mp3', description: 'Distant birds and leaves.'),
  SoundscapeMeta(id: 'ocean',  label: 'Ocean',  asset: 'assets/sounds/ocean.mp3',  description: 'Slow rolling surf.'),
  SoundscapeMeta(id: 'rain',   label: 'Rain',   asset: 'assets/sounds/rain.mp3',   description: 'Steady rainfall.'),
  SoundscapeMeta(id: 'fire',   label: 'Fire',   asset: 'assets/sounds/fire.mp3',   description: 'Crackling embers.'),
  SoundscapeMeta(id: 'wind',   label: 'Wind',   asset: 'assets/sounds/wind.mp3',   description: 'High mountain wind.'),
  SoundscapeMeta(id: 'waves',  label: 'Waves',  asset: 'assets/sounds/waves.mp3',  description: 'Gentle lapping water.'),
];

class AudioService {
  AudioService();

  final _player = AudioPlayer();
  String? _currentId;
  String? get currentId => _currentId;

  Future<void> play(String id, {double volume = 0.55}) async {
    final meta = kSoundscapes.where((s) => s.id == id).cast<SoundscapeMeta?>().firstOrNull;
    if (meta == null) return;
    try {
      await _player.setAsset(meta.asset);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(volume);
      _currentId = id;
      // Wrap play in unawaited try/catch — failure (e.g. missing asset) should not crash UI.
      await _player.play();
    } catch (e, s) {
      if (kDebugMode) debugPrint('audio play failed: $e\n$s');
      _currentId = null;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentId = null;
  }

  Future<void> setVolume(double v) async => _player.setVolume(v.clamp(0, 1));

  Future<void> dispose() async => _player.dispose();
}

extension _ListExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final s = AudioService();
  ref.onDispose(s.dispose);
  return s;
});

final currentSoundProvider = StateProvider<String?>((_) => null);
