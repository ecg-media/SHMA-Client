import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shma_client/models/channel.dart';
import 'package:shma_client/services/player/audio_handler.dart';
import 'package:shma_client/services/player/player_state.dart';

/// Service that handles all actions for playing records.
class PlayerService {
  /// Instance of the [PlayerService].
  static PlayerService? _instance;

  /// Audio handler that interacts with the player background service and the
  /// notification bar.
  late ShmaAudioHandler _audioHandler;

  /// Controller of the current showed bottom sheet, used to close the bottom
  /// sheet when necessary.
  PersistentBottomSheetController? _controller;

  /// State of the player.
  PlayerState? playerState;

  /// Private constructor of the [PlayerService].
  PlayerService._();

  /// Returns the singleton instance of the [PlayerService] or creates a new
  /// one.
  static PlayerService getInstance() {
    _instance ??= PlayerService._();

    return _instance!;
  }

  /// Sets the given [audioHandler] and initializes the necessary listeners.
  set audioHandler(ShmaAudioHandler audioHandler) {
    _audioHandler = audioHandler;
  }

  /// Stops the music and closes the player bottom sheet.
  Future closePlayer({bool stopAudioHandler = true}) async {
    if (stopAudioHandler) {
      await _audioHandler.stop();
    }

    _controller?.close();
    await _reset();
  }

  /// Plays the given [record] and opens the bottom [PlayerSheet] if not
  /// already done.
  Future play(
    BuildContext context,
    Channel current,
    StreamController<Uint8List> streamController,
  ) async {
    playerState ??= PlayerState(_audioHandler);
    await _audioHandler.streamChannel(current, streamController); // TODO stream);
    initializeListeners();
  }

  /// Initializes the listeners used to update the [PlayerState] and the gui.
  initializeListeners() {
    // _audioHandler.positionStream.listen(
    //   (event) {
    //     _audioHandler.currentSeekPosition =
    //         double.tryParse("${event.inMilliseconds}") ?? 0;

    //     playerState?.update();
    //   },
    // );

    // _audioHandler.playbackEventStream.listen(
    //   (event) {
    //     playerState?.update();
    //   },
    // );
  }

  /// Resets the current player.
  Future _reset() async {
    _audioHandler.currentSeekPosition = 0;
    _audioHandler.current = null;
    playerState?.update();
    playerState = null;
    _controller = null;
  }
}
