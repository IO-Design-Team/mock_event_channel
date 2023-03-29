import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_event_channel/mock_event_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('No arguments', (tester) async{
    const channel = EventChannel('mock_event_channel');
    channel.setMockStreamHandler(StreamHandler());

    final stream = channel.receiveBroadcastStream();
    stream.listen(print);
    await expectLater(
      stream,
      emitsInOrder(
        ['asdf', emitsError(PlatformException(code: 'asdf')), emitsDone],
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
