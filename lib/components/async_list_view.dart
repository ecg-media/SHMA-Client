import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shma_client/components/horizontal_spacer.dart';
import 'package:shma_client/models/channel.dart';
import 'package:flutter_gen/gen_l10n/shma_client_localizations.dart';

/// Function to load data with the passed [filter], starting from [offset] and
/// loading an amount of [take] data. Also a [subfilter] can be added to filter the list more specific.
typedef LoadDataFunction = Future<void> Function();

/// Function that is called when an action is performed on selected items the items with the passed [itemIdentifiers].
///
/// This function should return a [Future], that either resolves with true
/// after successful action or false on cancel.
/// The list will reload the data starting from beginning, if true will be
/// returned.
typedef ActionPerfomedFunction = Future<bool> Function<T>(
    List<T> itemIdentifiers);

/// Function that is called when an action is performed on selected items the items with the passed [itemIdentifiers].
///
/// This function should return a [Future], that either resolves with true
/// after successful action or false on cancel.
/// The list will reload the data starting from beginning, if true will be
/// returned.
typedef EventActionPerfomedFunction = Future<void> Function();

/// Function that updates the passed [item].
///
/// This function should return a [Future], that either resolves with true
/// after successful update or false on cancel.
/// The list will reload the data starting from beginning, if true will be
/// returned.
typedef EditFunction = Future<bool> Function(Channel item);

/// List that supports async loading of data, when necessary in chunks.
class AsyncListView extends StatefulWidget {
  /// Function to load data with the passed [filter], starting from [offset] and
  /// loading an amount of [take] data.
  final LoadDataFunction loadData;

  /// Called, when configuration button is pressed.
  final EventActionPerfomedFunction openConfiguration;

  final EventActionPerfomedFunction openSettings;

  /// Function that updates the passed [item].
  ///
  /// This function should return a [Future], that either resolves with true
  /// after successful update or false on cancel.
  /// The list will reload the data starting from beginning, if true will be
  /// returned.
  final EditFunction onItemTap;

  final List<Channel> data;

  /// Initializes the list view.
  const AsyncListView({
    Key? key,
    required this.data,
    required this.onItemTap,
    required this.loadData,
    required this.openConfiguration,
    required this.openSettings,
  }) : super(key: key);

  @override
  State<AsyncListView> createState() => _AsyncListViewState();
}

/// State of the list view.
class _AsyncListViewState extends State<AsyncListView> {
  /// List of lazy loaded items.
  List<Channel>? _items;

  /// Indicates, whether data is loading and an loading indicator should be
  /// shown.
  bool _isLoadingData = false;

  @override
  void initState() {
    _items = widget.data;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _items = widget.data;
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) => {
        if (event.isKeyPressed(LogicalKeyboardKey.f5)) {_reloadData()}
      },
      child: Scaffold(
        body: Column(
          children: [
            // List header with filter and action buttons.
            _createListHeaderWidget(),

            // List, loading indicator or no data widget.
            Expanded(
              child: _isLoadingData
                  ? _createLoadingWidget()
                  : (_items!.isNotEmpty
                      ? _createListViewWidget()
                      : _createNoDataWidget()),
            ),
          ],
        ),
      ),
    );
  }

  /// Reloads the data starting from inital offset with inital count.
  void _reloadData() {
    if (!mounted) {
      return;
    }

    _loadData();
  }

  /// Loads the data for the [_offset] and [_take] with the [_filter].
  ///
  /// Shows a loading indicator instead of the list during load, if
  /// [showLoadingOverlay] is true.
  /// Otherwhise the data will be loaded lazy in the background.
  void _loadData({
    bool showLoadingOverlay = true,
  }) {
    if (showLoadingOverlay) {
      setState(() {
        _isLoadingData = true;
      });
    }

    var dataFuture = widget.loadData();

    dataFuture.then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingData = false;
      });
    }).onError((e, _) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingData = false;
      });
    });
  }

  /// Creates the list header widget with filter and remove action buttons.
  Widget _createListHeaderWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => widget.openConfiguration(),
            icon: const Icon(Icons.qr_code),
            tooltip: AppLocalizations.of(context)!.connectionConfig,
          ),
          IconButton(
            onPressed: () => widget.openSettings(),
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }

  /// Creates the list view widget.
  Widget _createListViewWidget() {
    return RefreshIndicator(
      onRefresh: () async {
        _reloadData();
      },
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const Divider(
              height: 1,
            );
          },
          itemBuilder: (context, index) {
            return _createListTile(index);
          },
          itemCount: _items?.length ?? 0,
        ),
      ),
    );
  }

  /// Creates a loading indicator widget.
  Widget _createLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Creates a widget that will be shown, if no data were loaded or an error
  /// occured during loading of data.
  Widget _createNoDataWidget() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.noData,
            softWrap: true,
          ),
          horizontalSpacer,
          TextButton.icon(
            onPressed: () => _loadData(),
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.reload),
          ),
        ],
      ),
    );
  }

  /// Creates a tile widget for one list item at the given [index] or a group widget.
  Widget _createListTile(int index) {
    var item = _items![index];
    return _listTile(item, index);
  }

  /// Creates a tile widget for one list [item] at the given [index].
  ListTile _listTile(Channel item, int index) {
    return ListTile(
      minVerticalPadding: 5,
      visualDensity: const VisualDensity(vertical: 0),
      title: Wrap(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              item.title ?? "",
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
      onTap: () => widget.onItemTap(item),
    );
  }
}
