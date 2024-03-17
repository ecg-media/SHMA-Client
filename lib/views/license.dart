import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shma_client/components/header.dart';
import 'package:shma_client/view_models/license/license.dart';

/// License detail screen.
class LicenseScreen extends StatelessWidget {
  /// Initializes the instance.
  const LicenseScreen({super.key});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<LicenseViewModel>(
        create: (context) => LicenseViewModel(),
        builder: (context, _) {
          var vm = Provider.of<LicenseViewModel>(context, listen: false);

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
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(vm.package.license ?? ""),
                        ),
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
