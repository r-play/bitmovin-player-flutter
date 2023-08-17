import 'dart:io';

import 'package:bitmovin_player/bitmovin_player.dart';
import 'package:bitmovin_player/src/channel_manager.dart';
import 'package:bitmovin_player/src/channels.dart';
import 'package:bitmovin_player/src/methods.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A view that provides the Bitmovin Player Web UI and default UI handling to
/// an attached [Player] instance.
class PlayerView extends StatefulWidget {
  const PlayerView({
    required this.player,
    super.key,
    this.onViewCreated,
    this.fullscreenHandler,
  });

  /// The [Player] instance that is attached to this view.
  final Player player;

  /// Callback that is invoked when the view has been created and is ready to be
  /// used. Can be for instance used to load a source into the [player].
  final void Function()? onViewCreated;

  /// Handles entering and exiting fullscreen mode. A custom implementation
  /// needs to be provided that is aware of the view hierarchy where the
  /// [PlayerView] is embedded and can handle the UI state changes accordingly.
  final FullscreenHandler? fullscreenHandler;

  @override
  State<StatefulWidget> createState() => PlayerViewState();
}

class PlayerViewState extends State<PlayerView> {
  late final MethodChannel _methodChannel;

  void _onPlatformViewCreated(int id) {
    _methodChannel = ChannelManager.registerMethodChannel(
      name: '${Channels.playerView}-$id',
    );
    widget.onViewCreated?.call();
  }

  // TODO(mario): Should this be defined in `UserInterfaceApi`?
  bool get isFullscreen => widget.fullscreenHandler?.isFullscreen ?? false;

  // TODO(mario): Should this be defined in `UserInterfaceApi`?
  void enterFullscreen() {
    // TODO(mario): call platform side
    // HACK: Calling handler directly for testing purposes.
    widget.fullscreenHandler?.enterFullscreen();
  }

  // This is always called from the platform side.
  // void _handleEnterFullscreen() {
  //   widget.fullscreenHandler?.enterFullscreen();
  // }

  // TODO(mario): Should this be defined in `UserInterfaceApi`?
  void exitFullscreen() {
    // TODO(mario): call platform side
    // HACK: Calling handler directly for testing purposes.
    widget.fullscreenHandler?.exitFullscreen();
  }

  // This is always called from the platform side.
  // void _handleExitFullscreen() {
  //   widget.fullscreenHandler?.exitFullscreen();
  // }

  @override
  void dispose() {
    _methodChannel.invokeMethod(Methods.destroyPlayerView);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? PlatformViewLink(
            viewType: Channels.playerView,
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as ExpensiveAndroidViewController,
                gestureRecognizers: const <
                    Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initExpensiveAndroidView(
                id: params.id,
                viewType: Channels.playerView,
                layoutDirection: TextDirection.ltr,
                creationParams: widget.player.id,
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
                ..create();
            },
          )
        : UiKitView(
            viewType: Channels.playerView,
            layoutDirection: TextDirection.ltr,
            creationParams: widget.player.id,
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParamsCodec: const StandardMessageCodec(),
          );
  }
}
