import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shma_client/models/channel.dart';
import 'package:shma_client/services/player/player.dart';
import 'package:shma_client/util/assets.dart';

/// Audio handler that interacts with the player background service and the
/// notification bar.
///
/// Should not be used directly. Instead the playback should be modified with
/// the [PlayerService].
class ShmaAudioHandler extends BaseAudioHandler {
  /// [AudioPlayer] used to start  the native playback.
  FlutterSoundPlayer? _player;

  /// Currently played record.
  Channel? current;

  /// The current seek position of the playback.
  double currentSeekPosition = 0.0;

  /// Indicates, that the source to be played is loading.
  bool _isLoading = false;

  /// Creates an instance of the [ShmaAudioHandler] and initializes the
  /// listeners.
  ShmaAudioHandler();

  /// Bool, that indicates, whether the record is playing or not.
  bool get isPlaying => _player?.isPlaying ?? false;

  /// Indicates, that the source to be played is loading.
  bool get isLoading => _isLoading;

  /// Plays the given [record].
  Future<void> streamChannel(
    Channel channel,
    StreamController<Uint8List> streamController,
  ) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    current = channel;
    if (_player == null) {
      _initPlayer();
    }

    await _startStreaming(streamController);
    _isLoading = false;
  }

  /// Cretaes new instance of the [AudioPlayer], if player not exists yet.
  void _initPlayer() {
    _player ??= FlutterSoundPlayer();
  }

  @override
  Future<void> play() => _player!.startPlayer();

  @override
  Future<void> stop() async {
    if (_player != null) {
      await _player!.stopPlayer();
      await _player!.closePlayer();
      _player = null;
    }

    await PlayerService.getInstance().closePlayer(stopAudioHandler: false);
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _player!.stopPlayer();
  }

  /// Adds or updates the current playback notification message.
  void _addPlaybackState() {
    final playing = _player!.isPlaying;

    List<MediaControl> controls = [];
    List<int> compatIndices = [0];

    controls.addAll([
      MediaControl.stop,
    ]);

    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        androidCompactActionIndices: compatIndices,
        playing: playing,
      ),
    );
  }

  /// Plays the [currentRecord].
  Future<void> _startStreaming(
    StreamController<Uint8List> streamController,
  ) async {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final bgImageUri = (await getImageFileFromAssets(
      isDarkMode ? 'images/bg_dark.jpg' : 'images/bg_light.jpg',
    ))
        .uri;

    mediaItem.add(
      MediaItem(
        id: "${current!.id!}",
        title: current?.title ?? 'Unknown',
        artUri: bgImageUri,
      ),
    );

    await _player?.openPlayer(enableVoiceProcessing: false);
    await _player?.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 44100,
    );
    streamController.stream.listen((event) {
      print(event);
      _player?.foodSink?.add(FoodData(event));
    });
  }
}
