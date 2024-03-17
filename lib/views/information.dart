import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:shma_client/components/header.dart';
import 'package:shma_client/view_models/information.dart';

// Shows informations from the passed url in a webview.
class InformationScreen extends StatelessWidget {
  /// Initializes the instance.
  const InformationScreen({super.key});

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<InformationViewModel>(
        create: (context) => InformationViewModel(),
        builder: (context, _) {
          var vm = Provider.of<InformationViewModel>(context, listen: false);
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
                      title: '',
                      tooltip: vm.locales.back,
                    ),
                    Expanded(
                      child: InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(vm.url),
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
