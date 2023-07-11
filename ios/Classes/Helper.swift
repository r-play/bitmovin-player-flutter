import Foundation
import BitmovinPlayer

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class Helper {
    static func playerPayload(_ payload: Any?) -> PlayerPayload? {
        guard let json = payload as? [String: Any] else {
            return nil
        }

        guard let idString = json["id"] as? String, let id = Int(idString) else {
            return nil
        }

        let data = json["data"] as? [String: Any]

        return PlayerPayload(id: id, data: data)
    }

    /**
     Utility method to instantiate a `PlayerConfig` from a JS object.
     - Parameter json: JS object
     - Returns: The produced `PlayerConfig` object
     */
    static func playerConfig(_ json: [AnyHashable: Any]) -> PlayerConfig {
        let playerConfig = PlayerConfig()

        guard let json = json as? [String: Any] else {
            return playerConfig
        }

        if let licenseKey = json["key"] as? String {
            playerConfig.key = licenseKey
        }

        if let playbackConfig = playbackConfig(json["playbackConfig"]) {
            playerConfig.playbackConfig = playbackConfig
        }

        if let styleConfig = styleConfig(json["styleConfig"]) {
            playerConfig.styleConfig = styleConfig
        }

        if let tweaksConfig = tweaksConfig(json["tweaksConfig"]) {
            playerConfig.tweaksConfig = tweaksConfig
        }

        return playerConfig
    }

    /**
     Utility method to instantiate a `PlaybackConfig` from a JS object.
     - Parameter json: JS object.
     - Returns: The produced `PlaybackConfig` object.
     */
    static func playbackConfig(_ json: Any?) -> PlaybackConfig? {
        guard let json = json as? [String: Any?] else {
            return nil
        }
        let playbackConfig = PlaybackConfig()
        if let isAutoplayEnabled = json["isAutoplayEnabled"] as? Bool {
            playbackConfig.isAutoplayEnabled = isAutoplayEnabled
        }
        if let isMuted = json["isMuted"] as? Bool {
            playbackConfig.isMuted = isMuted
        }
        if let isTimeShiftEnabled = json["isTimeShiftEnabled"] as? Bool {
            playbackConfig.isTimeShiftEnabled = isTimeShiftEnabled
        }
        if let isBackgroundPlaybackEnabled = json["isBackgroundPlaybackEnabled"] as? Bool {
            playbackConfig.isBackgroundPlaybackEnabled = isBackgroundPlaybackEnabled
        }
        if let isPictureInPictureEnabled = json["isPictureInPictureEnabled"] as? Bool {
            playbackConfig.isPictureInPictureEnabled = isPictureInPictureEnabled
        }
        return playbackConfig
    }

    /**
     Utility method to instantiate a `StyleConfig` from a JS object.
     - Parameter json: JS object.
     - Returns: The produced `StyleConfig` object.
     */
    static func styleConfig(_ json: Any?) -> StyleConfig? {
        guard let json = json as? [String: Any?] else {
            return nil
        }
        let styleConfig = StyleConfig()
        if let isUiEnabled = json["isUiEnabled"] as? Bool {
            styleConfig.isUiEnabled = isUiEnabled
        }
        if let hideFirstFrame = json["isHideFirstFrame"] as? Bool {
#if os(iOS)
            let userInterfaceConfig = BitmovinUserInterfaceConfig()
#else
            let userInterfaceConfig = SystemUserInterfaceConfig()
#endif
            userInterfaceConfig.hideFirstFrame = hideFirstFrame
            styleConfig.userInterfaceConfig = userInterfaceConfig
        }
#if os(iOS)
        if let playerUiCss = json["playerUiCss"] as? String,
           let playerUiCssUrl = URL(string: playerUiCss) {
            styleConfig.playerUiCss = playerUiCssUrl
        }
        if let supplementalPlayerUiCss = json["supplementalPlayerUiCss"] as? String,
           let supplementalPlayerUiCssUrl = URL(string: supplementalPlayerUiCss) {
            styleConfig.supplementalPlayerUiCss = supplementalPlayerUiCssUrl
        }
        if let playerUiJs = json["playerUiJs"] as? String,
           let playerUiJsUrl = URL(string: playerUiJs) {
            styleConfig.playerUiJs = playerUiJsUrl
        }
#endif
        if let scalingMode = json["scalingMode"] as? String {
            switch scalingMode {
            case "Fit":
                styleConfig.scalingMode = .fit
            case "Stretch":
                styleConfig.scalingMode = .stretch
            case "Zoom":
                styleConfig.scalingMode = .zoom
            default:
                break
            }
        }
        return styleConfig
    }

    /**
     Utility method to instantiate a `TweaksConfig` from a JS object.
     - Parameter json: JS object.
     - Returns: The produced `TweaksConfig` object.
     */
    static func tweaksConfig(_ json: Any?) -> TweaksConfig? { // swiftlint:disable:this cyclomatic_complexity
        guard let json = json as? [String: Any?] else {
            return nil
        }

        let tweaksConfig = TweaksConfig()

        if let isNativeHlsParsingEnabled = json["isNativeHlsParsingEnabled"] as? Bool {
            tweaksConfig.isNativeHlsParsingEnabled = isNativeHlsParsingEnabled
        }

        if let isCustomHlsLoadingEnabled = json["isCustomHlsLoadingEnabled"] as? Bool {
            tweaksConfig.isCustomHlsLoadingEnabled = isCustomHlsLoadingEnabled
        }

        if let timeChangedInterval = json["timeChangedInterval"] as? NSNumber {
            tweaksConfig.timeChangedInterval = timeChangedInterval.doubleValue
        }

        if let seekToEndThreshold = json["seekToEndThreshold"] as? NSNumber {
            tweaksConfig.seekToEndThreshold = seekToEndThreshold.doubleValue
        }

        if let playbackStartBehaviour = json["playbackStartBehaviour"] as? String {
            switch playbackStartBehaviour {
            case "relaxed":
                tweaksConfig.playbackStartBehaviour = .relaxed
            case "aggressive":
                tweaksConfig.playbackStartBehaviour = .aggressive
            default:
                break
            }
        }

        if let unstallingBehaviour = json["unstallingBehaviour"] as? String {
            switch unstallingBehaviour {
            case "relaxed":
                tweaksConfig.unstallingBehaviour = .relaxed
            case "aggressive":
                tweaksConfig.unstallingBehaviour = .aggressive
            default:
                break
            }
        }

        return tweaksConfig
    }

    static func source(_ json: [String: Any]) -> (Source, FairplayConfig.Metadata?)? {
        guard let sourceConfigJson = json["sourceConfig"] as? [String: Any],
              let (sourceConfig, fairplayConfigMetadata) = sourceConfig(sourceConfigJson) else {
            return nil
        }

        return (
            SourceFactory.create(from: sourceConfig),
            fairplayConfigMetadata
        )
    }

    /**
     Utility method to instantiate a `SourceConfig` from a JS object.
     - Parameter json: JS object
     - Returns: The produced `SourceConfig` object
     */
    static func sourceConfig(_ json: [String: Any]) -> (SourceConfig, FairplayConfig.Metadata?)? {
        guard let sourceUrlString = json["url"] as? String,
              let sourceUrl = URL(string: sourceUrlString) else {
            return nil
        }

        let sourceConfig = SourceConfig(
            url: sourceUrl,
            type: sourceType(json["type"] as Any?)
        )

        var fairplayConfigMetadata: FairplayConfig.Metadata?

        if let drmConfig = json["drmConfig"] as? [String: Any],
           let fairplayConfigJson = drmConfig["fairplay"] as? [String: Any] {
            sourceConfig.drmConfig = fairplayConfig(fairplayConfigJson)
            fairplayConfigMetadata = Self.fairplayConfigMetadata(fairplayConfigJson)
        }

        if let title = json["title"] as? String {
            sourceConfig.title = title
        }

        if let poster = json["poster"] as? String {
            sourceConfig.posterSource = URL(string: poster)
        }

        if let isPosterPersistent = json["isPosterPersistent"] as? Bool {
            sourceConfig.isPosterPersistent = isPosterPersistent
        }

        if let subtitleTracks = json["subtitleTracks"] as? [[String: Any]] {
            subtitleTracks.forEach {
                if let track = subtitleTrack($0) {
                    sourceConfig.add(subtitleTrack: track)
                }
            }
        }

        if let thumbnailTrack = json["thumbnailTrack"] as? String {
            sourceConfig.thumbnailTrack = Helper.thumbnailTrack(thumbnailTrack)
        }

        return (sourceConfig, fairplayConfigMetadata)
    }

    /**
     Utility method to get a `SourceType` from a JS object.
     - Parameter json: JS object
     - Returns: The associated `SourceType` value
     */
    static func sourceType(_ json: Any?) -> SourceType {
        guard let json = json as? String else {
            return .none
        }
        switch json {
        case "none":
            return .none
        case "hls":
            return .hls
        case "dash":
            return .dash
        case "progressive":
            return .progressive
        default:
            return .none
        }
    }

    /**
     Utility method to get a `TimeMode` from a JS object.
     - Parameter json: JS object
     - Returns: The associated `TimeMode` value
     */
    static func timeMode(_ json: Any?) -> TimeMode {
        guard let json = json as? String else {
            return .absoluteTime
        }
        switch json {
        case "absolute":
            return .absoluteTime
        case "relative":
            return .relativeTime
        default:
            return .absoluteTime
        }
    }

    /**
     Utility method to get a `FairplayConfig` from a JS object.
     - Parameter json: JS object
     - Returns: The generated `FairplayConfig` object
     */
    static func fairplayConfig(_ json: [String: Any]) -> FairplayConfig? {
        guard let certificateUrlString = json["certificateUrl"] as? String,
              let certificateUrl = URL(string: certificateUrlString) else {
            return nil
        }

        var licenseUrl: URL?
        if let licenseUrlString = json["licenseUrl"] as? String {
            licenseUrl = URL(string: licenseUrlString)
        }

        let fairplayConfig = FairplayConfig(license: licenseUrl, certificateURL: certificateUrl)

        if let licenseRequestHeaders = json["licenseRequestHeaders"] as? [String: String] {
            fairplayConfig.licenseRequestHeaders = licenseRequestHeaders
        }

        if let certificateRequestHeaders = json["certificateRequestHeaders"] as? [String: String] {
            fairplayConfig.certificateRequestHeaders = certificateRequestHeaders
        }

        return fairplayConfig
    }

    /// Returns a `FairplayConfig.Metadata` object that tells which callbacks from `FairplayConfig` are implemented
    /// on the Dart side.
    ///
    /// - Parameter json: JSON representation of `FairplayConfig`.
    /// - Returns: The created `FairplayConfig.Metadata` object.
    private static func fairplayConfigMetadata(_ fairplayConfig: [String: Any]) -> FairplayConfig.Metadata {
        return FairplayConfig.Metadata(
            hasPrepareMessage: fairplayConfig["prepareMessage"] as? Bool ?? false,
            hasPrepareContentId: fairplayConfig["prepareContentId"] as? Bool ?? false,
            hasPrepareCertificate: fairplayConfig["prepareCertificate"] as? Bool ?? false,
            hasPrepareLicense: fairplayConfig["prepareLicense"] as? Bool ?? false,
            hasPrepareLicenseServerUrl: fairplayConfig["prepareLicenseServerUrl"] as? Bool ?? false,
            hasPrepareSyncMessage: fairplayConfig["prepareSyncMessage"] as? Bool ?? false
        )
    }

    /**
     Utility method to get a `ThumbnailTrack` instance from a JS object.
     - Parameter url: String.
     - Returns: The generated `ThumbnailTrack`.
     */
    static func thumbnailTrack(_ url: String?) -> ThumbnailTrack? {
        guard
            let url = URL(string: url!)
        else {
            return nil
        }
        return ThumbnailTrack(
            url: url,
            label: "Thumbnails",
            identifier: UUID().uuidString,
            isDefaultTrack: false
        )
    }

    /**
     Utility method to get a json dictionary value from a `AudioTrack` object.
     - Parameter audioTrack: The track to convert to json format.
     - Returns: The generated json dictionary.
     */
    static func audioTrackJson(_ audioTrack: AudioTrack) -> [AnyHashable: Any] {
        [
            "url": audioTrack.url?.absoluteString ?? "",
            "label": audioTrack.label,
            "isDefault": audioTrack.isDefaultTrack,
            "identifier": audioTrack.identifier,
            "language": audioTrack.language ?? ""
        ]
    }

    /**
     Utility method to get a `SubtitleTrack` instance from a JS object.
     - Parameter json: JS object.
     - Returns: The generated `SubtitleTrack`.
     */
    static func subtitleTrack(_ json: [String: Any]) -> SubtitleTrack? {
        guard let urlString = json["url"] as? String,
              let url = URL(string: urlString),
              let label = json["label"] as? String else {
            return nil
        }

        let language = json["language"] as? String
        let isDefaultTrack = json["isDefault"] as? Bool ?? false
        let isForced = json["isForced"] as? Bool ?? false
        let identifier = json["identifier"] as? String ?? UUID().uuidString

        if let format = subtitleFormat(json["format"]) {
            return SubtitleTrack(
                url: url,
                format: format,
                label: label,
                identifier: identifier,
                isDefaultTrack: isDefaultTrack,
                language: language,
                forced: isForced
            )
        }

        return SubtitleTrack(
            url: url,
            label: label,
            identifier: identifier,
            isDefaultTrack: isDefaultTrack,
            language: language,
            forced: isForced
        )
    }

    /**
     Utility method to get a `SubtitleFormat` value from a JS object.
     - Parameter json: JS object.
     - Returns: The associated `SubtitleFormat` value or nil.
     */
    static func subtitleFormat(_ json: Any?) -> SubtitleFormat? {
        guard let json = json as? String else {
            return nil
        }
        switch json {
        case "cea": return .cea
        case "vtt": return .webVtt
        case "ttml": return .ttml
        default: return nil
        }
    }

    /**
     Utility method to get a json dictionary value from a `SubtitleTrack` object.
     - Parameter subtitleTrack: The track to convert to json format.
     - Returns: The generated json dictionary.
     */
    static func subtitleTrackJson(_ subtitleTrack: SubtitleTrack) -> [AnyHashable: Any] {
        [
            "url": subtitleTrack.url?.absoluteString ?? "",
            "label": subtitleTrack.label,
            "isDefault": subtitleTrack.isDefaultTrack,
            "identifier": subtitleTrack.identifier,
            "language": subtitleTrack.language ?? "",
            "isForced": subtitleTrack.isForced,
            "format": {
                switch subtitleTrack.format {
                case .cea:
                    return "cea"
                case .webVtt:
                    return "vtt"
                case .ttml:
                    return "ttml"
                default:
                    return ""
                }
            }()
        ]
    }

    /**
     Utility method to compute a JS value from a `VideoQuality` object.
     - Parameter videoQuality `VideoQuality` object to be converted.
     - Returns: The produced JS object.
     */
    static func toJson(videoQuality: VideoQuality) -> [String: Any] {
        var result: [String: Any] = [
            "id": videoQuality.identifier,
            "label": videoQuality.label,
            "height": videoQuality.height,
            "width": videoQuality.width,
            "bitrate": videoQuality.bitrate
        ]

        if let codec = videoQuality.codec {
            result["codec"] = codec
        }

        return result
    }
}
