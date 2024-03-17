import 'package:flutter/material.dart';
import 'package:shma_client/oss_licenses.dart';
import 'package:shma_client/services/router.dart';
import 'package:shma_client/view_models/license/license.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';

class LicenseOverviewViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/licenses_overview';

  late BuildContext _context;
    /// Locales of the application.
  late AppLocalizations locales;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) async {
    _context = context;
    locales = AppLocalizations.of(_context)!;
    return Future<bool>.microtask(() async {
      return true;
    });
  }

  /// Opens a license details screen for the passed [package].
  void showLicense(Package package) {
    RouterService.getInstance().pushNestedRoute(
      _context,
      LicenseViewModel.route,
      arguments: package,
    );
  }
}
