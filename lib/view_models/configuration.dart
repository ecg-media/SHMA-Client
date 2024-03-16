import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shma_client/components/delete_dialog.dart';
import 'package:shma_client/models/connection.dart';
import 'package:shma_client/services/db.dart';

class ConfigurationViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/config';

  /// Locales of the application.
  late AppLocalizations locales;

  late BuildContext _context;
  final DBService _dbService = DBService.getInstance();

  late Connection config;

  ConfigState state = ConfigState.init;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) async {
    _context = context;
    locales = AppLocalizations.of(_context)!;

    return Future<bool>.microtask(() async {
      config = await _dbService.loadConfig();
      _init();
      return true;
    });
  }

  void register(Barcode barcode) async {
    if (barcode.rawValue == null) {
      return;
    }
    try {
      config = Connection.fromJson(jsonDecode(barcode.rawValue!));
      if (config.isValid) {
        await _dbService.createConfig(config);
        if (_context.mounted) Navigator.pop(_context, true);
      }
    } on Exception catch (_, e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> reset() async {
    var shouldReset = await showDeleteDialog(_context);
    if (shouldReset) {
      await _dbService.deleteConfig(config);
      config = Connection();
      _init();
      notifyListeners();
    }
  }

  void _init() {
    if (!config.isValid) {
      state = ConfigState.scan;
    } else {
      state = ConfigState.edit;
    }
  }
}

enum ConfigState {
  init,
  scan,
  edit,
}
