import 'package:flutter/material.dart';
import 'package:shma_client/models/channel.dart';
import 'package:shma_client/services/player/audio_handler.dart';

/// State of the player used to display changes on the [PlayerSheet].
class PlayerState extends ChangeNotifier {
  /// [AudioHandler] that handles the play state.
  final ShmaAudioHandler _audioHandler;

  /// Initializes the player state.
  PlayerState(this._audioHandler);

  /// The current played record.
  Channel? get current => _audioHandler.current;

  /// The current sekk position of the played record.
  double get currentSeekPosition => _audioHandler.currentSeekPosition;

  /// Bool, that indicates, whether the record is playing or not.
  bool get isPlaying => _audioHandler.isPlaying;

  /// Indicates, that the source to be played is loading.
  bool get isLoading => _audioHandler.isLoading;

  /// Notifies for changes the listeners.
  ///
  /// Should be used if the state changes.
  void update() {
    notifyListeners();
  }
}
