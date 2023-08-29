import 'dart:async';

import 'package:bitmovin_player/bitmovin_player.dart';
import 'single_event_expectation.dart';

class PlayerWorld {
  PlayerWorld._();
  static final _instance = PlayerWorld._();
  static PlayerWorld get sharedWorld => _instance;

  Player? _player;

  Future<void> startPlayerTest(
    PlayerConfig playerConfig,
  ) async {
    if (_player != null) {
      await _player?.dispose();
      _player = null;
    }

    _player = Player(config: playerConfig);
  }

  Future<T> callPlayerAndExpectEvent<T extends Event>(
    Future<void> Function(Player) playerCaller,
    T event,
  ) async {
    final completer = Completer<T>();
    final eventReceived = completer.future;

    _player?.onEvent = (receivedEvent) {
      if (!completer.isCompleted && receivedEvent is T) {
        completer.complete(receivedEvent);
      }
    };

    await playerCaller.call(_player!);
    return eventReceived;
  }

  Future<void> callPlayer(
    Future<void> Function(Player) playerCaller,
  ) async {
    await playerCaller.call(_player!);
  }

  Future<T> expectEvent<T extends Event>(T event) async {
    final completer = Completer<T>();
    final eventReceived = completer.future;

    _player?.onEvent = (receivedEvent) {
      if (!completer.isCompleted && receivedEvent is T) {
        completer.complete(receivedEvent);
      }
    };

    return eventReceived;
  }

  Future<T> expectSingleEvent<T extends Event>(
      SingleEventExpectation<T> eventExpectation) async {
    final completer = Completer<T>();
    final eventReceived = completer.future;

    _player?.onEvent = (receivedEvent) {
      if (!completer.isCompleted &&
          eventExpectation.maybeFulfillExpectation(receivedEvent)) {
        completer.complete(receivedEvent as T);
      }
    };

    return eventReceived;
  }
}
