import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shma_client/models/channel.dart';
import 'package:shma_client/models/connection.dart';
import 'package:shma_client/util/demo.dart';

/// Service that holds all routing information of the navigators of the app.
class SocketService {
  /// Instance of the Socket service.
  static final SocketService _instance = SocketService._();

  /// Private constructor of the service.
  SocketService._();

  /// Returns the singleton instance of the [SocketService].
  static SocketService getInstance() {
    return _instance;
  }

  final String _socketMessageLoadChannels = 'de.wekode.shma.channels';

  bool _running = false;
  Socket? _socket;
  Socket? _channelStream;

  Future<void> start(
    Connection connection,
    ValueSetter<List<Channel>> onChannelsReceived,
  ) async {
    if (_running) {
      return;
    }

    if (connection.isDemo) {
      onChannelsReceived([
        Channel(id: 0, title: "Demo", port: 42),
      ]);
      return;
    }

    _socket = await Socket.connect(connection.host, connection.port!);
    _running = true;
    _socket!.listen(
      // handle data from the server
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        if (kDebugMode) print('Server responds with: $serverResponse');
        var items = jsonDecode(serverResponse);
        onChannelsReceived(
          List.generate(
            items.length,
            (index) => Channel.fromJson(
              items[index],
            ),
          ),
        );
      },

      // handle errors
      onError: (error) {
        if (kDebugMode) print(error);
        _socket!.destroy();
      },

      // handle server ending connection
      onDone: () {
        if (kDebugMode) print('Server left.');
        _socket!.destroy();
      },
    );
  }

  Future<void> stop() async {
    _socket?.destroy();
    _socket = null;
    _running = false;
  }

  Future<void> restart(
    Connection connection,
    ValueSetter<List<Channel>> onChannelsReceived,
  ) async {
    await stop();
    await start(connection, onChannelsReceived);
  }

  Future<void> requestChannels() async {
    if (_socket == null) {
      return;
    }
    _socket!.write(_socketMessageLoadChannels);
  }

  Future<void> startListenToChannel(
    String host,
    Channel channel,
    ValueSetter<Uint8List> onReceived,
    VoidCallback onFinished,
  ) async {
    if (host == '127.0.0.1') {
      for (var pcm in demo) {
        onReceived(Uint8List.fromList(pcm));
      }
      onFinished();
      return;
    }

    _channelStream = await Socket.connect(host, channel.port!);
    _channelStream!.listen(
      // handle data from the server
      (Uint8List data) {
        onReceived(data);
      },

      // handle errors
      onError: (error) {
        if (kDebugMode) print(error);
        onFinished();
        _channelStream?.close();
      },

      // handle server ending connection
      onDone: () {
        if (kDebugMode) print('Channel stream left.');
        onFinished();
        _channelStream?.close();
      },
    );
    // _channelStream!.write(_socketMessageStartStream);
  }

  Future<void> stopListenToChannel() async {
    _channelStream?.close();
    _channelStream = null;
  }
}
