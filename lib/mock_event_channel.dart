import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension on [EventChannel] to allow mocking of the stream
extension TestEventChannelExtension on TestDefaultBinaryMessenger {
  /// Set a mock stream handler for this channel
  void setMockStreamHandler(EventChannel channel, MockStreamHandler handler) {
    final controller = StreamController<dynamic>();

    setMockMethodCallHandler(MethodChannel(channel.name, channel.codec),
        (call) async {
      switch (call.method) {
        case 'listen':
          return handler.onListen(
            call.arguments,
            MockStreamHandlerEventSink(controller.sink),
          );
        case 'cancel':
          return handler.onCancel(call.arguments);
        default:
          throw UnimplementedError('Method ${call.method} not implemented');
      }
    });

    final sub = controller.stream.listen(
      (e) => channel.binaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeSuccessEnvelope(e),
        null,
      ),
    );
    sub.onError((e) {
      if (e is! PlatformException) {
        throw ArgumentError('Stream error must be a PlatformException');
      }
      channel.binaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeErrorEnvelope(
          code: e.code,
          message: e.message,
          details: e.details,
        ),
        null,
      );
    });
    sub.onDone(
      () => channel.binaryMessenger
          .handlePlatformMessage(channel.name, null, null),
    );
    addTearDown(sub.cancel);
  }
}

/// A mock stream handler for an [EventChannel]
abstract class MockStreamHandler {
  /// Handler for the listen event
  void onListen(dynamic arguments, MockStreamHandlerEventSink events);

  /// Handler for the cancel event
  void onCancel(dynamic arguments);
}

/// A mock event sink for a [MockStreamHandler]
class MockStreamHandlerEventSink {
  final EventSink<dynamic> _sink;

  /// Constructor
  MockStreamHandlerEventSink(this._sink);

  /// Send a success event
  void success(dynamic event) => _sink.add(event);

  /// Send an error event
  void error({
    required String code,
    String? message,
    Object? details,
  }) =>
      _sink.addError(
        PlatformException(code: code, message: message, details: details),
      );

  /// Send an end of stream event
  void endOfStream() => _sink.close();
}
