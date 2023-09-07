import Foundation
import BitmovinPlayer


// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class Helper {
    static func methodCallArguments(_ payload: Any?) -> MethodCallArguments? {
        guard let jsonPayload = payload as? [String: Any?],
              let data = jsonPayload["data"] else {
            return nil
        }

        switch data {
        case let jsonArgument as [String: Any]:
            return .json(jsonArgument)
        case let doubleArgument as Double:
            return .double(doubleArgument)
        default:
            return .empty
        }
    }

    static func toJSONString(_ dictionary: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return jsonString
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

        if let liveConfig = liveConfig(json["liveConfig"]) {
            playerConfig.liveConfig = liveConfig
        }

        return playerConfig
    }
    
    private struct AnalyticsConfigInternal: Codable {
        let licenseKey: String
        let retryPolicy: String
        let randomizeUserId: Bool
        let adTrackingDisabled: Bool
        let backendUrl: String
        let defaultMetadata: DefaultMetadataInternal
        
        func toAnalyticsConfig() -> AnalyticsConfig {
            let retryPolicy: RetryPolicy
            switch self.retryPolicy {
            case "NoRetry":
                retryPolicy = RetryPolicy.noRetry
                break
            case "LongTerm":
                retryPolicy = RetryPolicy.longTerm
                break;
            case "ShortTerm":
                // TODO: is this enum value not available on iOS?
                retryPolicy = RetryPolicy.longTerm
                break;
            default:
                // TODO: should we throw here?
                // fallback to no-retry
                retryPolicy = RetryPolicy.noRetry
                break;
            }
            
            return AnalyticsConfig(licenseKey: licenseKey,
                                                  retryPolicy: retryPolicy,
                                                  randomizeUserId: randomizeUserId,
                                                  adTrackingDisabled: adTrackingDisabled,
                                                  backendUrl: backendUrl)
        }
    }
    
    static func analyticsConfig(_ json: Any?) -> AnalyticsConfig? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard let analyticsConfigInternal = MessageDecoder.decode(type: AnalyticsConfigInternal.self, from: json) else {
            fatalError("Could not decode AnalyticsConfig")
        }
        return analyticsConfigInternal.toAnalyticsConfig()
        
    }
    
    static func defaultMetadata(_ json: Any?) -> DefaultMetadata? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard let analyticsConfigInternal = MessageDecoder.decode(type: AnalyticsConfigInternal.self, from: json) else {
            fatalError("Could not decode AnalyticsConfig for defaultMetadata")
        }
        return analyticsConfigInternal.defaultMetadata.toDefaultMetadata()
    }
    
    private struct CustomDataInternal: Codable {
        let customData1: String?
        let customData2: String?
        let customData3: String?
        let customData4: String?
        let customData5: String?
        let customData6: String?
        let customData7: String?
        let customData8: String?
        let customData9: String?
        let customData10: String?
        let customData11: String?
        let customData12: String?
        let customData13: String?
        let customData14: String?
        let customData15: String?
        let customData16: String?
        let customData17: String?
        let customData18: String?
        let customData19: String?
        let customData20: String?
        let customData21: String?
        let customData22: String?
        let customData23: String?
        let customData24: String?
        let customData25: String?
        let customData26: String?
        let customData27: String?
        let customData28: String?
        let customData29: String?
        let customData30: String?
        let experimentName: String?
        
        func toCustomData() -> CustomData {
            return CustomData(customData1: customData1,
                              customData2: customData2,
                              customData3: customData3,
                              customData4: customData4,
                              customData5: customData5,
                              customData6: customData6,
                              customData7: customData7,
                              customData8: customData8,
                              customData9: customData9,
                              customData10: customData10,
                              customData11: customData11,
                              customData12: customData12,
                              customData13: customData13,
                              customData14: customData14,
                              customData15: customData15,
                              customData16: customData16,
                              customData17: customData17,
                              customData18: customData18,
                              customData19: customData19,
                              customData20: customData20,
                              customData21: customData21,
                              customData22: customData22,
                              customData23: customData23,
                              customData24: customData24,
                              customData25: customData25,
                              customData26: customData26,
                              customData27: customData27,
                              customData28: customData28,
                              customData29: customData29,
                              customData30: customData30,
                              experimentName: experimentName)
        }
    }
    

    
    private struct DefaultMetadataInternal: Codable {
        let cdnProvider: String?
        let customUserId: String?
        let customData: CustomDataInternal
        
        func toDefaultMetadata() -> DefaultMetadata {
            return DefaultMetadata(cdnProvider: cdnProvider,
            customUserId: customUserId,
                                   customData: customData.toCustomData())
        }
    }
        
    private struct SourceMetadataInternal: Codable {
        let videoId: String?
        let title: String?
        let path: String?
        let isLive: Bool?
        let cdnProvider: String?
        let customData: CustomDataInternal

        func toSourceMetadata() -> SourceMetadata {
            return SourceMetadata(videoId: videoId,
                                  title: title,
                                  path: path,
                                  isLive: isLive,
                                  cdnProvider: cdnProvider,
                                  customData: customData.toCustomData())
        }
    }
    
    static func sourceMetadata(_ json: Any?) -> SourceMetadata? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard let sourceMetadataInternal = MessageDecoder.decode(type: SourceMetadataInternal.self, from: json) else {
            fatalError("Could not decode SourceMetadata")
        }
        
        return sourceMetadataInternal.toSourceMetadata()
    }
    
    static func customData(_ json: Any?) -> CustomData? {
        guard let json = json as? [String: Any] else {
            return nil
        }
        
        guard let customDataInternal = MessageDecoder.decode(type: CustomDataInternal.self, from: json) else {
            fatalError("Could not decode CustomData")
        }
        
        return customDataInternal.toCustomData()
    }

    static func liveConfig(_ json: Any?) -> LiveConfig? {
        guard let json = json as? [String: Any] else {
            return nil
        }

        let liveConfig = LiveConfig()

        if let minTimeShiftBufferDepth = json["minTimeShiftBufferDepth"] as? TimeInterval {
            liveConfig.minTimeshiftBufferDepth = minTimeShiftBufferDepth
        }

        return liveConfig
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
            type: sourceType(json["type"])
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

        if let description = json["description"] as? String {
            sourceConfig.sourceDescription = description
        }

        if let posterSource = json["posterSource"] as? String {
            sourceConfig.posterSource = URL(string: posterSource)
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

        if let options = json["options"] as? [String: Any] {
            sourceConfig.options = sourceOptions(options)
        }

        if let thumbnailTrack = json["thumbnailTrack"] as? String {
            sourceConfig.thumbnailTrack = Helper.thumbnailTrack(thumbnailTrack)
        }

        return (sourceConfig, fairplayConfigMetadata)
    }

    static func sourceOptions(_ json: [String: Any]) -> SourceOptions {
        let sourceOptions = SourceOptions()

        if let startOffset = json["startOffset"] as? Double {
            sourceOptions.startOffset = startOffset
        }

        sourceOptions.startOffsetTimelineReference = timelineReferencePoint(json["startOffsetTimelineReference"])

        return sourceOptions
    }

    static func timelineReferencePoint(_ json: Any?) -> TimelineReferencePoint {
        guard let json = json as? String else {
            return .auto
        }

        switch json {
        case "Start":
            return .start
        case "End":
            return .end
        default:
            return .auto
        }
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
