import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class AutoReconnectWebSocket {
  final Uri url;
  WebSocketChannel? _channel;
  StreamController _outerStreamController = StreamController.broadcast();
  bool _isUserDisconnected = false;
  int _retryDelaySeconds = 2;

  AutoReconnectWebSocket(this.url);

  // Expose the stream to your UI or Blocs/Providers
  Stream get stream => _outerStreamController.stream;

  void connect() {
    _isUserDisconnected = false;
    _establishConnection();
  }

  void _establishConnection() {
    if (_isUserDisconnected) return;

    print("Connecting to WebSocket: $url");
    _channel = WebSocketChannel.connect(url);

    _channel!.stream.listen(
          (message) {
        // Reset backoff delay on a successful message
        _retryDelaySeconds = 2;
        _outerStreamController.add(message);
      },
      onError: (error) {
        print("WebSocket Error: $error");
        _handleReconnection();
      },
      onDone: () {
        print("WebSocket Closed by Server/Network.");
        _handleReconnection();
      },
      cancelOnError: true,
    );
  }

  void _handleReconnection() {
    if (_isUserDisconnected) return;

    _channel?.sink.close();
    print("Reconnecting in $_retryDelaySeconds seconds...");

    Timer(Duration(seconds: _retryDelaySeconds), () {
      // Exponential backoff logic maxing out at 30 seconds
      if (_retryDelaySeconds < 30) {
        _retryDelaySeconds *= 2;
      }
      _establishConnection();
    });
  }

  // Send message through the current active sink
  void sendMessage(String message) {
    if (_channel != null && _isUserDisconnected == false) {
      _channel!.sink.add(message);
    } else {
      print("Cannot send message. Device is disconnected.");
    }
  }

  // Explicitly close when exiting the app or feature
  void disconnect() {
    _isUserDisconnected = true;
    _channel?.sink.close();
    _outerStreamController.close();
  }
}
