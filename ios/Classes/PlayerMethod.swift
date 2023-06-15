import Foundation
import Flutter
import BitmovinPlayer

class PlayerMethod: NSObject, FlutterStreamHandler {
    private var id: String
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    init(id: String) {
        self.id = id
    }

    // TODO: Should probably become the initializer
    static func create(id: String, playerConfig: PlayerConfig?, messenger: FlutterBinaryMessenger) {
        let instance = PlayerMethod(id: id)
        instance.methodChannel = FlutterMethodChannel(name: Channels.player + "-\(id)", binaryMessenger: messenger)
        instance.methodChannel?.setMethodCallHandler(instance.handleMethodCall)

        instance.eventChannel = FlutterEventChannel(name: Channels.playerEvent + "-\(id)", binaryMessenger: messenger)
        // TODO: Check if this is a retain cycle and this is the reason why the `PlayerMethod` instance is not
        // deallocated. It is not retained anywhere else.
        instance.eventChannel?.setStreamHandler(instance)

        PlayerManager.shared.createPlayer(id: id, config: playerConfig)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        let player = PlayerManager.shared.players[self.id]
        player?.add(listener: self)
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    private func getPlayer() -> Player? {
        return PlayerManager.shared.players[self.id]
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let player = getPlayer(),
              let payload = Helper.playerPayload(call.arguments) else {
            result(FlutterError())
            return
        }

        switch call.method {
        case Methods.loadWithSourceConfig:
            if let payloadData = payload.data, let config = Helper.sourceConfig(payloadData) {
                player.load(sourceConfig: config)
            } else {
                result(FlutterError())
            }
        case Methods.play:
            player.play()
        case Methods.pause:
            player.pause()
        case Methods.mute:
            player.mute()
        case Methods.unmute:
            player.unmute()
        case Methods.seek:
            player.seek(time: 1)
        case Methods.currentTime:
            result(player.currentTime)
        case Methods.duration:
            result(player.duration)
        case Methods.destroy:
            PlayerManager.shared.destroy(id: self.id)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension PlayerMethod: PlayerListener {
    func toJSONString(_ dictionary: [String: Any]) -> String? {
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            // TODO: fix all occurrences of this error
            print("[error] invalid json object found")
            return nil
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("[error] converting dictionary to JSON string: \(error.localizedDescription)")
        }
        return nil
    }

    func broadCast(name: String, data: [String: Any], sink: FlutterEventSink?) {
        let target = [
            "event": name,
            "data": toJSONString(data)
        ]
        sink?(toJSONString(target as [String: Any]))
    }

    func onSourceAdded(_ event: SourceAddedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSourceRemoved(_ event: SourceRemovedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSourceLoad(_ event: SourceLoadEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSourceLoaded(_ event: SourceLoadedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSourceUnloaded(_ event: SourceUnloadedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSourceUnload(_ event: SourceUnloadEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSourceWarning(_ event: SourceWarningEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSourceError(_ event: SourceErrorEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onReady(_ event: ReadyEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onDestroy(_ event: DestroyEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onPlayerError(_ event: PlayerErrorEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onPlayerWarning(_ event: PlayerWarningEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onPlay(_ event: PlayEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onPlaying(_ event: PlayingEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onTimeChanged(_ event: TimeChangedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onPaused(_ event: PausedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onMuted(_ event: MutedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onUnmuted(_ event: UnmutedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSeek(_ event: SeekEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }

    func onSeeked(_ event: SeekedEvent, player: Player) {
        broadCast(name: event.name, data: event.toJSON(), sink: eventSink)
    }
}
