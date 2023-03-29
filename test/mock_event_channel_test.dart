import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_event_channel/mock_event_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('No arguments', () {
    const channel = EventChannel('mock_event_channel');
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockStreamHandler(channel, StreamHandler1());

    final stream = channel.receiveBroadcastStream();
    expectLater(
      stream,
      emitsInOrder(
        [
          'asdf',
          emitsError(
            isA<PlatformException>().having((e) => e.code, 'code', 'asdf'),
          ),
          emitsDone
        ],
      ),
    );
  });

  test('With arguments', () {
    const channel = EventChannel('mock_event_channel');
    final handler = StreamHandler2();
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockStreamHandler(channel, handler);

    const arguments = 'asdf';
    final stream = channel.receiveBroadcastStream(arguments);
    expectLater(stream, emitsInOrder([arguments]));
    expectLater(handler.canceled.future, completion(arguments));
  });
}

class StreamHandler1 extends MockStreamHandler {
  @override
  void onListen(dynamic arguments, MockStreamHandlerEventSink events) {
    events.success('asdf');
    events.error(code: 'asdf');
    events.endOfStream();
  }

  @override
  void onCancel(dynamic arguments) {}
}

class StreamHandler2 extends MockStreamHandler {
  final canceled = Completer<dynamic>();

  @override
  void onListen(dynamic arguments, MockStreamHandlerEventSink events) {
    events.success(arguments);
  }

  @override
  void onCancel(dynamic arguments) {
    canceled.complete(arguments);
  }
}
