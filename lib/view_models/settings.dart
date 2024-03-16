import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';
import 'package:shma_client/models/connection.dart';

class SettingsViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/settings';

  /// Locales of the application.
  late AppLocalizations locales;

  late Connection config;
}