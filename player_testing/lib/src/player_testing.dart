import 'dart:async';

import 'package:bitmovin_player/bitmovin_player.dart';
import 'package:player_testing/env/env.dart';
import 'package:player_testing/src/events.dart';
import 'package:player_testing/src/player_world.dart';
import 'package:player_testing/src/single_event_expectation.dart';

Future<void> startPlayerTest(
  Future<void> Function() testBlock, {
  PlayerConfig playerConfig =
      const PlayerConfig(key: Env.bitmovinPlayerLicenseKey),
}) async {
  await PlayerWorld.sharedWorld.startPlayerTest(playerConfig);
  await testBlock.call();
}

Future<dynamic> loadSourceConfig(
  SourceConfig sourceConfig,
) async {
  await PlayerWorld.sharedWorld.callPlayerAndExpectEvent(
    (player) async {
      await player.loadSourceConfig(sourceConfig);
    },
    E.ready,
  );
}

Future<T> callPlayerAndExpectEvent<T extends Event>(
  Future<void> Function(Player) playerCaller,
  T event,
) async {
  return PlayerWorld.sharedWorld.callPlayerAndExpectEvent(playerCaller, event);
}

Future<void> callPlayer(
  Future<void> Function(Player) playerCaller,
) async {
  return PlayerWorld.sharedWorld.callPlayer(playerCaller);
}

Future<T> expectEvent<T extends Event>(T event) async {
  return PlayerWorld.sharedWorld.expectEvent(event);
}

Future<T> expectSingleEvent<T extends Event>(
  SingleEventExpectation<T> eventExpectation,
) async {
  return PlayerWorld.sharedWorld.expectSingleEvent(eventExpectation);
}
