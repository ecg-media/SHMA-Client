import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';
import 'package:shma_client/models/channel.dart';
import 'package:shma_client/models/connection.dart';
import 'package:shma_client/services/db.dart';
import 'package:shma_client/services/messenger.dart';
import 'package:shma_client/services/player/player.dart';
import 'package:shma_client/services/socket.dart';

class StreamViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/stream';

  /// Locales of the application.
  late AppLocalizations locales;
  late BuildContext _context;

  final DBService _dbService = DBService.getInstance();
  final SocketService _socketService = SocketService.getInstance();
  final _msgService = MessengerService.getInstance();
  final _playerService = PlayerService.getInstance();

  final StreamController<Uint8List> _streamController =
      StreamController<Uint8List>();

  late Connection config;
  late Channel channel;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) async {
    _context = context;
    locales = AppLocalizations.of(_context)!;

    return Future<bool>.microtask(() async {
      channel = ModalRoute.of(context)!.settings.arguments as Channel;
      config = await _dbService.loadConfig();
      try {
        await _socketService.startListenToChannel(
          config.host!,
          channel,
          (receivedData) {
            if (!_streamController.isClosed) {
              _streamController.add(receivedData);
            }
          },
          () {
            _playerService.closePlayer();
            _streamController.close();
          },
        );
        if (_context.mounted) {
          await _playerService.play(_context, channel, _streamController);
        }
      } on Exception catch (_, e) {
        if (kDebugMode) print(e);
        _msgService.showMessage(_msgService.errorChannelConnectionFailed);
        await stop();
      }
      return true;
    });
  }

  Future<void> stop() async {
    await _playerService.closePlayer();
    await _streamController.close();
    await _socketService.stopListenToChannel();
    if (_context.mounted) Navigator.of(_context).pop();
  }
}
