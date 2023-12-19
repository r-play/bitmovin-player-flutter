package com.bitmovin.player.flutter

import android.app.Activity
import android.content.ComponentCallbacks
import android.content.Context
import android.content.ContextWrapper
import android.content.res.Configuration
import android.view.View
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.bitmovin.player.PlayerView
import com.bitmovin.player.api.ui.PictureInPictureHandler
import com.bitmovin.player.flutter.json.JPlayerViewCreateArgs
import com.bitmovin.player.flutter.ui.FlutterPictureInPictureHandler
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * Wraps a Bitmovin `PlayerView` and is connected to a player view instance that was created on the
 * Flutter side in Dart. Communication with the player view instance on the Flutter side happens
 * through the method channel.
 */
class FlutterPlayerView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    args: Any?,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler, PlatformView, EventListener() {
    private val methodChannel: MethodChannel =
        MethodChannel(
            messenger,
            "${Channels.PLAYER_VIEW}-$id",
        ).apply { setMethodCallHandler(this@FlutterPlayerView) }
    private val eventChannel =
        ChannelManager.registerEventChannel(
            "${Channels.PLAYER_VIEW_EVENT}-$id",
            this@FlutterPlayerView,
            messenger,
        )

    private val playerView = PlayerView(context, player = null)

    private val activity =
        context.getActivity()
            ?: error("Trying to create an instance of ${this::class.simpleName} while not attached to an Activity")

    private var isInPictureInPictureMode = activity.isInPictureInPictureMode
    private val configurationChangedCallback =
        object : ComponentCallbacks {
            override fun onConfigurationChanged(newConfig: Configuration) {
                val newInPictureInPictureMode = activity.isInPictureInPictureMode
                if (isInPictureInPictureMode != newInPictureInPictureMode) {
                    isInPictureInPictureMode = newInPictureInPictureMode
                    onPictureInPictureModeChanged(newInPictureInPictureMode, newConfig)
                }
            }

            override fun onLowMemory() = Unit
        }
    private var pictureInPicturehandler: PictureInPictureHandler? = null

    private val activityLifecycle =
        (activity as? LifecycleOwner)
            ?.lifecycle
            ?: error("Trying to create an instance of ${this::class.simpleName} while not attached to a LifecycleOwner")

    private val activityLifecycleObserver =
        object : DefaultLifecycleObserver {
            override fun onStart(owner: LifecycleOwner) = playerView.onStart()

            override fun onResume(owner: LifecycleOwner) = playerView.onResume()

            override fun onPause(owner: LifecycleOwner) = playerView.onPause()

            override fun onStop(owner: LifecycleOwner) = playerView.onStop()

            override fun onDestroy(owner: LifecycleOwner) = dispose()
        }

    init {
        val playerViewCreateArgs = JPlayerViewCreateArgs(args as Map<*, *>)

        PlayerManager.onPlayerCreated(playerViewCreateArgs.playerId) { player ->
            playerView.player = player
            if (playerViewCreateArgs.hasFullscreenHandler) {
                playerView.setFullscreenHandler(
                    FullscreenHandlerProxy(
                        isFullscreen = playerViewCreateArgs.isFullscreen,
                        methodChannel = methodChannel,
                    ),
                )
            }
            if (playerViewCreateArgs.playerViewConfig?.pictureInPictureConfig?.isEnabled == true) {
                pictureInPicturehandler = FlutterPictureInPictureHandler(activity, player)
                playerView.setPictureInPictureHandler(pictureInPicturehandler)
            }
        }

        activityLifecycle.addObserver(activityLifecycleObserver)
        activity.registerComponentCallbacks(configurationChangedCallback)
    }

    private fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration,
    ) {
        playerView.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        if (isInPictureInPictureMode) {
            playerView.enterPictureInPicture()
        } else {
            playerView.exitPictureInPicture()
        }
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) = when (val method = call.method) {
        Methods.ENTER_FULLSCREEN -> playerView.enterFullscreen()
        Methods.EXIT_FULLSCREEN -> playerView.exitFullscreen()
        Methods.IS_PICTURE_IN_PICTURE -> result.success(playerView.isPictureInPicture)
        Methods.IS_PICTURE_IN_PICTURE_AVAILABLE -> result.success(playerView.isPictureInPictureAvailable)
        Methods.ENTER_PICTURE_IN_PICTURE -> playerView.enterPictureInPicture()
        Methods.EXIT_PICTURE_IN_PICTURE -> playerView.exitPictureInPicture()
        Methods.DESTROY_PLAYER_VIEW -> Unit // no-op
        else -> throw NotImplementedError("$method not implemented.")
    }

    override fun getView(): View = playerView

    override fun dispose() {
        playerView.player = null
        playerView.onDestroy()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        activityLifecycle.removeObserver(activityLifecycleObserver)
        activity.unregisterComponentCallbacks(configurationChangedCallback)
    }

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?,
    ) {
        sink = events
        listenToEvent(playerView)
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun Context.getActivity(): Activity? =
        when (this) {
            is Activity -> this
            is ContextWrapper -> baseContext.getActivity()
            else -> null
        }
}
