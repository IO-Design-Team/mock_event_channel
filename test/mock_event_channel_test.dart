import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_event_channel/mock_event_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('No arguments', () {
    const channel = EventChannel('mock_event_channel');
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockStreamHandler(
      channel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          events.success('asdf');
          events.error(code: 'asdf');
          events.endOfStream();
        },
      ),
    );

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
    final canceled = Completer<dynamic>();
    const channel = EventChannel('mock_event_channel');
    final handler = MockStreamHandler.inline(
      onListen: (arguments, events) => events.success(arguments),
      onCancel: canceled.complete,
    );
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockStreamHandler(channel, handler);

    const arguments = 'asdf';
    final stream = channel.receiveBroadcastStream(arguments);
    expectLater(stream, emitsInOrder([arguments]));
    expectLater(canceled.future, completion(arguments));
  });
}
