import 'package:flutter/material.dart';
import 'package:shma_client/oss_licenses.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';

/// View model of a license detail screen.
class LicenseViewModel extends ChangeNotifier {
  /// Route of the license screen.
  static String route = '/license';

  late Package package;
    /// Locales of the application.
  late AppLocalizations locales;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) async {
    locales = AppLocalizations.of(context)!;
    return Future<bool>.microtask(() async {
      package = ModalRoute.of(context)!.settings.arguments as Package;
      return true;
    });
  }
}