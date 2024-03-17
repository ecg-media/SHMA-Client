import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shma_client/components/header.dart';
import 'package:shma_client/oss_licenses.dart';
import 'package:shma_client/view_models/license/license_overview.dart';

/// Overview screen of licenses of all used packages.
class LicenseOverviewScreen extends StatelessWidget {
  /// Initializes the instance.
  const LicenseOverviewScreen({super.key});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<LicenseOverviewViewModel>(
        create: (context) => LicenseOverviewViewModel(),
        builder: (context, _) {
          var vm =
              Provider.of<LicenseOverviewViewModel>(context, listen: false);

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
                      title: vm.locales.licenses,
                      tooltip: vm.locales.back,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ossLicenses.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(ossLicenses[index].name),
                            onTap: () {
                              vm.showLicense(ossLicenses[index]);
                            },
                          );
                        },
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
