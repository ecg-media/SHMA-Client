import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shma_client/components/header.dart';
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
          return FutureBuilder(
            future: vm.init(context),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return SafeArea(
                child: Column(
                  children: [
                    Header(
                      title: vm.locales.settings,
                      tooltip: vm.locales.back,
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -4),
                            title: Text(
                              vm.locales.settings,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          // if (vm.supportEMail.isNotEmpty)
                          //   ListTile(
                          //     leading: const Icon(Icons.feedback),
                          //     title: Text(vm.locales.sendFeedback),
                          //     onTap: vm.sendFeedback,
                          //   ),
                          if (vm.privacyLink.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.verified_user),
                              title: Text(vm.locales.privacyPolicy),
                              onTap: vm.showPrivacyPolicy,
                            ),
                          if (vm.legalInfoLink.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.privacy_tip),
                              title: Text(vm.locales.legalInformation),
                              onTap: vm.showLegalInformation,
                            ),
                          ListTile(
                            leading: const Icon(Icons.key),
                            title: Text(vm.locales.licenses),
                            onTap: vm.showLicensesOverview,
                          ),
                          ListTile(
                            leading: const Icon(Icons.new_releases),
                            title: Text(vm.version),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
