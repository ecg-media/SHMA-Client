import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shma_client/models/channel.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';
import 'package:shma_client/models/connection.dart';
import 'package:shma_client/services/db.dart';
import 'package:shma_client/services/messenger.dart';
import 'package:shma_client/services/player/audio_handler.dart';
import 'package:shma_client/services/player/player.dart';
import 'package:shma_client/services/router.dart';
import 'package:shma_client/services/socket.dart';
import 'package:shma_client/view_models/configuration.dart';
import 'package:shma_client/view_models/settings.dart';
import 'package:shma_client/view_models/stream.dart';

class MainViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/';

  late BuildContext _context;

  /// Locales of the application.
  late AppLocalizations locales;

  final DBService _dbService = DBService.getInstance();
  final RouterService _routerService = RouterService.getInstance();
  final SocketService _socketService = SocketService.getInstance();

  late Connection config;
  List<Channel> channels = [];

  /// Initializes the view model.
  Future<bool> init(BuildContext context) async {
    _context = context;
    locales = AppLocalizations.of(_context)!;

    return Future<bool>.microtask(() async {
      _initApp();
      await _loadConfig();
      if (!config.isValid) {
        manageConfiguration();
      } else {
        await load();
      }
      return true;
    });
  }

  Future<bool> openStream(item) async {
    await await _routerService.pushNestedRoute(
      _context,
      StreamViewModel.route,
      arguments: item,
    );
    return true;
  }

  Future<void> load() async {
    try {
      await _socketService.restart(config, (updatedChannels) {
        channels = updatedChannels;
        notifyListeners();
      });
      await _socketService.requestChannels();
    } on Exception catch (_, e) {
      if (kDebugMode) print(e);
      var msgService = MessengerService.getInstance();
      msgService.showMessage(msgService.errorConnectionFailed);
      channels.clear();
    }
  }

  Future<void> _loadConfig() async {
    config = await _dbService.loadConfig();
  }

  Future<void> manageConfiguration() async {
    await _routerService.pushNestedRoute(
      _context,
      ConfigurationViewModel.route,
    );

    await _loadConfig();
    await load();
  }

  Future<void> goToSettings() async {
    await _routerService.pushNestedRoute(
      _context,
      SettingsViewModel.route,
    );
  }

  Future _initApp() async {
    var notificationColor = Theme.of(_context).colorScheme.inverseSurface;
    PlayerService.getInstance().audioHandler = await AudioService.init(
      builder: () => ShmaAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'de.wekode.shma.audio',
        androidNotificationChannelName: locales.appTitle,
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        notificationColor: notificationColor,
        androidNotificationIcon: 'mipmap/ic_notification',
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
      ),
    );
  }
}
