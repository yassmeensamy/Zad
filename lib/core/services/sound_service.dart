import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import '../utils/logger.dart';

/// Short feedback sounds played on top of whatever else the device is playing.
///
/// Every clip has several variants so a long quiz session doesn't repeat the
/// same sting back to back.
abstract class SoundService {
  /// Warms the asset cache so the first answer isn't delayed by a disk copy.
  Future<void> preload();

  /// Played when the user picks the correct choice.
  Future<void> playCorrect();

  /// Played when the user picks a wrong choice.
  Future<void> playWrong();

  /// Played once when the level-complete result screen lands.
  Future<void> playLevelComplete();

  /// Cuts off anything still playing, e.g. when leaving the quiz.
  Future<void> stop();
}

class SoundServiceImpl implements SoundService {
  SoundServiceImpl({Random? random}) : _random = random ?? Random();

  static const _correctClips = <String>[
    'voices/right_gentle_rise_1.mp3',
    'voices/right_gentle_rise_2.mp3',
    'voices/right_sparkle_ding_1.mp3',
    'voices/right_sparkle_ding_2.mp3',
    'voices/right_cheerful_chime.mp3',
    'voices/right_achievement.mp3',
  ];

  static const _wrongClips = <String>[
    'voices/wrong_soft_buzz_1.mp3',
    'voices/wrong_soft_buzz_2.mp3',
    'voices/wrong_soft_buzz_3.mp3',
    'voices/wrong_deflate.mp3',
    'voices/wrong_peep.mp3',
  ];

  /// Longer, warmer stings than the per-answer ones: they land once at the end
  /// of a level, not between questions.
  static const _levelCompleteClips = <String>[
    'voices/level_alhamdulillah.mp3',
    'voices/level_cheerful_chime.mp3',
    'voices/level_joyful_cheer.mp3',
  ];

  /// Game feedback semantics: mixes with any audio already playing and stays
  /// silent while the device is muted, instead of grabbing the media session.
  static final _sfxContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  final Random _random;
  final AudioPlayer _player = AudioPlayer();

  String? _lastClip;
  Future<void>? _ready;

  @override
  Future<void> preload() => _ensureReady();

  /// Configures the player and copies the clips out of the bundle, once.
  /// Failures are swallowed so a device without working audio still lets the
  /// quiz run; the next call simply retries.
  Future<void> _ensureReady() {
    return _ready ??= () async {
      try {
        await _player.setReleaseMode(ReleaseMode.stop);
        await _player.setAudioContext(_sfxContext);
        await _player.audioCache.loadAll([
          ..._correctClips,
          ..._wrongClips,
          ..._levelCompleteClips,
        ]);
      } catch (e) {
        logger.error('SoundService.preload failed: $e');
        _ready = null;
      }
    }();
  }

  @override
  Future<void> playCorrect() => _play(_correctClips);

  @override
  Future<void> playWrong() => _play(_wrongClips);

  @override
  Future<void> playLevelComplete() => _play(_levelCompleteClips);

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      logger.error('SoundService.stop failed: $e');
    }
  }

  Future<void> _play(List<String> clips) async {
    await _ensureReady();
    final clip = _pick(clips);
    try {
      // A single player is reused, so an in-flight clip is replaced rather
      // than layered on top of the new one.
      await _player.stop();
      await _player.play(AssetSource(clip));
    } catch (e) {
      // Audio is decoration: a device that refuses to play must not break the
      // quiz flow.
      logger.error('SoundService.play failed for $clip: $e');
    }
  }

  /// Picks a random variant, never the one that just played.
  String _pick(List<String> clips) {
    final candidates = clips.length > 1
        ? [
            for (final clip in clips)
              if (clip != _lastClip) clip,
          ]
        : clips;
    final clip = candidates[_random.nextInt(candidates.length)];
    _lastClip = clip;
    return clip;
  }
}
