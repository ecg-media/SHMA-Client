import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shma_client/services/router.dart';
import 'package:shma_client/view_models/information.dart';
import 'package:shma_client/view_models/license/license_overview.dart';

class SettingsViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/settings';

  /// Locales of the application.
  late AppLocalizations locales;

  /// Build context.
  late BuildContext _context;

  /// Router service used for navigation.
  final RouterService _routerService = RouterService.getInstance();

  /// Link of the privacy policy.
  final String privacyLink = "";

  /// Link of the legal informations.
  final String legalInfoLink = "";

  /// E-Mail adress for support requests.
  final String supportEMail = "";

  /// version of the running app.
  late String version;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) {
    return Future.microtask(() async {
      _context = context;
      locales = AppLocalizations.of(context)!;
      var pkgInfo = await PackageInfo.fromPlatform();
      version = pkgInfo.version;
      return true;
    });
  }

  /// Redirects to the license overview screen.
  void showLicensesOverview() {
    _routerService.pushNestedRoute(
      _context,
      LicenseOverviewViewModel.route,
    );
  }

  /// Redirects to the legal information webview screen.
  void showLegalInformation() {
    _routerService.pushNestedRoute(
      _context,
      InformationViewModel.route,
      arguments: legalInfoLink,
    );
  }

  /// Redirects to the privacy policy webview screen.
  void showPrivacyPolicy() {
    _routerService.pushNestedRoute(
      _context,
      InformationViewModel.route,
      arguments: privacyLink,
    );
  }
}
