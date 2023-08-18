NOTE: These changes are included in Flutter 3.13.0. This package is no longer needed.
___

Temporary package to add support for mocking EventChannels in Flutter

## Features

Adds `setMockStreamHandler` to `TestDefaultBinaryMessenger` with an extension

## Usage

<!-- embedme example/example.dart -->
```dart
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
}

```

## Additional information

This package will be discontinued when this PR gets released to stable: https://github.com/flutter/flutter/pull/124415

This package is an exact copy of that code, so all you need to do when that PR is released is remove this package from your pubspec.
