import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shma_client/view_models/stream.dart';

class StreamScreen extends StatelessWidget {
  /// Initializes the instance.
  const StreamScreen({Key? key}) : super(key: key);

  /// Builds the main screen with the navigator instance.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: ChangeNotifierProvider<StreamViewModel>(
          create: (context) => StreamViewModel(),
          builder: (context, _) {
            var vm = Provider.of<StreamViewModel>(context, listen: false);
            return FutureBuilder(
              future: vm.init(context),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(vm.channel.title ?? ''),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: IconButton(
                            onPressed: () => vm.stop(),
                            icon: const Icon(
                              Icons.stop_circle_rounded,
                              size: 96,
                            ),
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
      ),
    );
  }
}
