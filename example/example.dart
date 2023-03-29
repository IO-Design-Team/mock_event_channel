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
      InlineMockStreamHandler(
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
}
