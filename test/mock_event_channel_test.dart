import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_event_channel/mock_event_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('No arguments', () {
    const channel = EventChannel('mock_event_channel');
    channel.setMockStreamHandler(StreamHandler());

    final stream = channel.receiveBroadcastStream();
    final sub = stream.listen(print);
    sub.onError((e) => print('asdfsdfkdfjksfd'));
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

class StreamHandler extends MockStreamHandler {
  @override
  void onListen(dynamic arguments, MockStreamHandlerEventSink events) {
    events.success('asdf');
    events.error(code: 'asdf');
    events.endOfStream();
  }

  @override
  void onCancel(dynamic arguments) {}
}
