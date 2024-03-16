import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shma_client/view_models/settings.dart';

class SettingsScreen extends StatelessWidget {
  /// Initializes the instance.
  const SettingsScreen({Key? key}) : super(key: key);

  /// Builds the main screen with the navigator instance.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<SettingsViewModel>(
        create: (context) => SettingsViewModel(),
        builder: (context, _) {
          var vm = Provider.of<SettingsViewModel>(context, listen: false);
          return SafeArea(child: Text("TODO: SETTINGS"));
          // return FutureBuilder(
          //   future: vm.init(context),
          //   builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          //     if (!snapshot.hasData) {
          //       return const Center(child: CircularProgressIndicator());
          //     }

          //     return SafeArea(
          //       child: AsyncListView(
          //         onItemTap: (item) => vm.openStream(item),
          //         loadData: () {
          //           return vm.load();
          //         },
          //         openConfiguration: () => vm.manageConfiguration(),
          //         openSettings: () => vm.goToSettings(),
          //       ),
          //     );
          //   },
          // );
        },
      ),
    );
  }
}
