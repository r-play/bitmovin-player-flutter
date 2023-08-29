class Methods {
  /// Player related methods
  static const String createPlayer = 'createPlayer';
  static const String loadWithSourceConfig = 'loadWithSourceConfig';
  static const String loadWithSource = 'loadWithSource';
  static const String play = 'play';
  static const String pause = 'pause';
  static const String mute = 'mute';
  static const String unmute = 'unmute';
  static const String seek = 'seek';
  static const String currentTime = 'currentTime';
  static const String duration = 'duration';
  static const String destroy = 'destroy';
  static const String setTimeShift = 'setTimeShift';
  static const String getTimeShift = 'getTimeShift';
  static const String maxTimeShift = 'maxTimeShift';
  static const String isLive = 'isLive';
  static const String isPlaying = 'isPlaying';

  /// Player view related methods
  static const String destroyPlayerView = 'destroyPlayerView';
  static const String enterFullscreen = 'enterFullscreen';
  static const String exitFullscreen = 'exitFullscreen';

  /// Fairplay DRM related methods
  static const String fairplayPrepareMessage = 'fairplayPrepareMessage';
  static const String fairplayPrepareContentId = 'fairplayPrepareContentId';
  static const String fairplayPrepareCertificate = 'fairplayPrepareCertificate';
  static const String fairplayPrepareLicense = 'fairplayPrepareLicense';
  static const String fairplayPrepareLicenseServerUrl =
      'fairplayPrepareLicenseServerUrl';
  static const String fairplayPrepareSyncMessage = 'fairplayPrepareSyncMessage';

  /// Widevine DRM related methods
  static const String widevinePrepareMessage = 'widevinePrepareMessage';
  static const String widevinePrepareLicense = 'widevinePrepareLicense';
}
