import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';

class InformationViewModel extends ChangeNotifier {
  /// Route of the main screen.
  static String route = '/information';

  late String url;

  /// Locales of the application.
  late AppLocalizations locales;

  /// Initializes the view model.
  Future<bool> init(BuildContext context) async {
    locales = AppLocalizations.of(context)!;
    return Future<bool>.microtask(() async {
      url = ModalRoute.of(context)!.settings.arguments as String;
      return true;
    });
  }
}
