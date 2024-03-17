import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String tooltip;
  final String title;

  /// Initializes the instance.
  const Header({
    Key? key,
    required this.title,
    required this.tooltip,
  }) : super(key: key);

  /// Builds the main screen with the navigator instance.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back),
          tooltip: tooltip,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(title),
            ),
          ),
        ),
      ],
    );
  }
}
