import 'dart:convert';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart' as bc;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shma_client/components/progress_indicator.dart';
import 'package:shma_client/components/vertical_spacer.dart';
import 'package:shma_client/view_models/configuration.dart';

class ConfigurationScreen extends StatelessWidget {
  /// Initializes the instance.
  const ConfigurationScreen({Key? key}) : super(key: key);

  /// Builds the main screen with the navigator instance.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<ConfigurationViewModel>(
        create: (context) => ConfigurationViewModel(),
        builder: (context, _) {
          var vm = Provider.of<ConfigurationViewModel>(context, listen: false);
          return FutureBuilder(
            future: vm.init(context),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return SafeArea(
                child: Column(
                  children: [
                    _header(context, vm),
                    Consumer<ConfigurationViewModel>(
                      builder: (context, vm, child) {
                        return vm.state == ConfigState.init
                            ? showProgressIndicator()
                            : vm.state == ConfigState.scan
                                ? Expanded(child: _setup(context, vm))
                                : Expanded(child: _edit(context, vm));
                      },
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

  Widget _header(
    BuildContext context,
    ConfigurationViewModel vm,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back),
          tooltip: vm.locales.back,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                vm.locales.connectionConfig,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _setup(BuildContext context, ConfigurationViewModel vm) {
    // TODO Add possibilty to add configuration manually by text fields in further versions.
    // works only on mobile
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return const Text('NOT SUPPORTED YET!');
    }

    return Center(
      child: Container(
        height: 256,
        width: 256,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 6.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: MobileScanner(
          controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
          ),
          onDetect: (capture) {
            final Barcode barcode = capture.barcodes.first;
            vm.register(barcode);
          },
        ),
      ),
    );
  }

  Widget _edit(BuildContext context, ConfigurationViewModel vm) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bc.BarcodeWidget(
            padding: const EdgeInsets.all(15),
            barcode: bc.Barcode.qrCode(),
            color: Theme.of(context).colorScheme.primary,
            height: 256,
            width: 256,
            data: jsonEncode(vm.config.toJson()),
            errorBuilder: (context, error) => Center(
              child: Text(error),
            ),
          ),
          Text("${vm.locales.connectionHost}: ${vm.config.host}"),
          Text("${vm.locales.connectionPort}: ${vm.config.port}"),
          verticalSpacer,
          verticalSpacer,
          verticalSpacer,
          TextButton.icon(
            onPressed: () => vm.reset(),
            icon: const Icon(Icons.delete),
            label: Text(vm.locales.connectionDelete),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                (Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
