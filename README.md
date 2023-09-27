# Bitmovin Flutter SDK (Beta) 

Official Flutter bindings for Bitmovin's mobile Player SDKs, currently in Beta.

> As the library is under active development, this means certain features from our native SDKs are not yet exposed 
> through these Flutter bindings. See [Feature Support](#feature-support) for an overview of the supported features.
>
> Not seeing the features you’re looking for?
> We are accepting community pull requests to this open-source project, so please feel free to contribute 
> or let us know in [our community](https://community.bitmovin.com/c/requests/14) what features we should work on next.

## Platform Support 

* iOS/iPadOS 14.0+
* Android API Level 16+

## Feature Support

Features of the native mobile Player SDKs are progressively being implemented in this Flutter library. The table below summarizes the current state of the main Player SDK features.

| Feature | Android | iOS, iPadOS |
| :--- | :--- | :--- |
| Supported media formats | DASH, HLS, Progressive | HLS, Progressive |
| Playback of DRM-protected media | &#9989; (Widevine) | &#9989; (FairPlay) |
| Bitmovin Web UI | &#9989; | &#9989;|
| Full-screen support | &#9989; | &#9989; |
| [Bitmovin Analytics](https://developer.bitmovin.com/playback/docs/enabling-bitmovin-analytics) | &#9989; | &#9989; |
| Subtitles & Captions | &#9989; | &#9989; |
| Support for Apple TV / Android TV / Fire TV | &#9203; Planned for H2, 2023 | &#9203; Planned for H2, 2023 |
| Casting | &#9203; Planned for H2, 2023 | &#9203; Planned for H2, 2023 |
| AirPlay | &#9203; Planned for H2, 2023 | &#9203; Planned for H2, 2023 |
| Picture-in-Picture | Later | Later |
| Background Playback | Later | Later |
| Advertising (Google IMA CSAI) | Later | Later |
| Offline Playback | Later | Later |
| Playlist API | Later | Later |

> **Note:**
> Some of the unavailable features mentioned above already work to some degree. 
> 
> For instance, it is possible to use the AirPlay button from the Bitmovin Player UI to play back content on an AirPlay 
> receiver. However, AirPlay related player events, API calls and configuration options are not yet fully exposed to the 
> Dart side. 
> 
> The same holds for subtitles and captions. They are available to be selected from the UI and they are also rendered, 
> however, the full API surface related to subtitles is not yet available from Dart code.

# Get Started
If you want to play around with the code, implement a new feature or just run the example apps, follow along with this section. If you just want to use the player in your own flutter app, you can skip this and follow the instructions in the [Installation](#installation) section.

- [Install](https://docs.flutter.dev/get-started/install) `flutter` on your machine
- Install `Node.js` and `npm` on your machine
- Run `npm ci` in the root of the cloned repository
  - This will setup [husky](https://github.com/typicode/husky) powered pre-commit git hooks
- Run `brew bundle install` in the root of the cloned repository to install needed dependencies:
  - `ktlint` for linting Kotlin code
  - `swiftlint` for linting Swift code

## For iOS Development
To build the example project with your own developer account, create the config file 
`example/ios/Flutter/Developer.xcconfig`. In this file, add your development team like this:

```yml
DEVELOPMENT_TEAM = YOUR_TEAM_ID
```

## Example App
To be able to use the example app, follow these steps:
1. Create a file named `.env` in the project root
1. Put your private Bitmovin Player license key inside the newly created `.env` file as `BITMOVIN_PLAYER_LICENSE_KEY=YOUR_LICENSE_KEY`, replacing `YOUR_LICENSE_KEY` with your license key which can be obtained from [Bitmovin's Dashboard](https://bitmovin.com/dashboard)
1. If you also want to enable Bitmovin Analytics, additionally add your private Bitmovin Analytics license key to the `.env` file as 
`BITMOVIN_ANALYTICS_LICENSE_KEY=YOUR_ANALYTICS_LICENSE_KEY`, replacing `YOUR_ANALYTICS_LICENSE_KEY` with your Analytics 
license key which can be obtained from [Bitmovin's Dashboard](https://bitmovin.com/dashboard)
1. In the [Dashboard](https://bitmovin.com/dashboard), add `com.bitmovin.player.flutter.example` as an allowed package name for your Player license and optionally for your Analytics license
1. Run `flutter pub get` in the project root, if not done already
1. Run `dart run build_runner build --delete-conflicting-outputs` in the project root which should generate the missing `example/lib/env/env.g.dart` file
1. Start the example app by running the command `flutter run` inside the `example/` directory
    1. If you see an error that signing for "Runner" requires a development team, follow the instructions in the section for [getting started with iOS development](#for-ios-development)

# Installation
The `bitmovin_player` package is still under development and not yet published to [pub.dev](https://pub.dev). 
However, it can be used as a local dependency in any Flutter app. To do so, add the `bitmovin_player` dependency with the
correct relative path to your app's `pubspec.yaml` as show exemplary below:

```yml
dependencies:
  bitmovin_player:
    path: ./../bitmovin-player-flutter
```

## Android Specific Steps
1. Add Bitmovin's Maven repository to `android/build.gradle`:
     ```groovy
    allprojects {
        repositories {
            google()
            mavenCentral()
            
            maven {
                url 'https://artifacts.bitmovin.com/artifactory/public-releases'
            }
        }
    }
     ```

2. Enable Multidex support if needed. Follow this guide to enable it: https://developer.android.com/build/multidex

3. If you are using `android:label`, `android:allowBackup` or `android:supportsRtl` in your application's 
`AndroidManifest.xml` please enable field replacement, otherwise the build will fail with a manifest merger error.

    For example:
    ```xml
    <application
         android:label="@string/app_name"
         tools:replace="android:label">
         ...
    </application>
    ```
    The need for this workaround will be removed with a future release.

## iOS Specific Steps
Add Bitmovin's CocoaPods repo as a source on top of `ios/Podfile`:
```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
```

If you see any errors during `pod install` after adding the source from above, try deleting `Podfile.lock` and do a 
fresh `pod install`. At this point, `pod install` might fail due to the incorrect minimum deployment target being set 
for the `Runner` project. Set the deployment target and minimum deployment version to at least iOS 14 in `Runner` 
project to fix this.

```ruby
platform :ios, '14.0'
source 'https://github.com/bitmovin/cocoapod-specs.git'

## The rest of your Podfile ##
```

## Providing a Bitmovin Player License Key
When a `Player` instance is created, it will need a Bitmovin Player license key which has to be set in the `PlayerConfig` that is used to create the `Player`. 

To obtain a Bitmovin Player license key, please visit [Bitmovin's Dashboard](https://bitmovin.com/dashboard). Furthermore, make sure to associate your iOS and Android app bundle identifiers with your license key. More information on that can be found [here](https://bitmovin.com/docs/player/getting-started/ios#step-3-configure-your-player-license).

Now, you can provide your license key via the `PlayerConfig`:
```dart
final player = Player(
  config: const PlayerConfig(
    key: 'YOUR_LICENSE_KEY',
  ),
);
```

# Example code
The example app demonstrates some of the most basic but also more advanced use cases how the Bitmovin Player can be used and integrated. Please refer to the [Example App](#example-app) section to learn how to run it.

The code for the different examples is located under [example/lib/pages](example/lib/pages). This is a good place to start learning about how to use the player.

# Documentation
To generate code documentation files, run `dart doc .` in the root folder of the repository.

# Contributing
See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.
