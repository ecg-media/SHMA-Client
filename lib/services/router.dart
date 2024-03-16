import 'package:flutter/material.dart';
import 'package:shma_client/view_models/configuration.dart';
import 'package:shma_client/view_models/main.dart';
import 'package:shma_client/view_models/settings.dart';
import 'package:shma_client/view_models/stream.dart';
import 'package:shma_client/views/configuration.dart';
import 'package:shma_client/views/main.dart';
import 'package:shma_client/views/settings.dart';
import 'package:shma_client/views/stream.dart';

/// Service that holds all routing information of the navigators of the app.
class RouterService {
  /// Instance of the router service.
  static final RouterService _instance = RouterService._();

  /// GlobalKey of the state of the main navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  /// Private constructor of the service.
  RouterService._();

  /// Returns the singleton instance of the [RouterService].
  static RouterService getInstance() {
    return _instance;
  }

  /// Routes of the main navigator.
  Map<String, Widget Function(BuildContext)> get routes {
    return {
      MainViewModel.route: (context) => const MainScreen(),
      SettingsViewModel.route: (context) => const SettingsScreen(),
      StreamViewModel.route: (context) => const StreamScreen(),
      ConfigurationViewModel.route: (context) => const ConfigurationScreen(),
    };
  }

  /// Name of the initial route for the main navigation.
  String get initialRoute {
    return MainViewModel.route;
  }

  /// Routes of the nested navigator.
  Map<String, Route<dynamic>?> get nestedRoutes {
    return {
      // RecordsViewModel.route: PageRouteBuilder(
      //   pageBuilder: (context, animation1, animation2) => const RecordsScreen(),
      //   transitionDuration: const Duration(seconds: 0),
      // ),
    };
  }

  /// Pops the latest route of the nested navigator.
  void popNestedRoute(BuildContext context) {
    Navigator.pop(context);
  }

  /// Pushes the route with the passed [name] and [arguments] to the nested
  /// navigator.
  Future pushNestedRoute(
    BuildContext context,
    String name, {
    Object? arguments,
  }) async {
    await Navigator.pushNamed(context, name, arguments: arguments);
  }
}
