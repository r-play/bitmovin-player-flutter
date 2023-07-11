import 'package:flutter/material.dart';
import 'package:bitmovin_player_example/pages/basic_playback.dart';
import 'package:bitmovin_player_example/pages/basic_playback_with_event_subscription.dart';
import 'package:bitmovin_player_example/pages/basic_player_only.dart';
import 'package:bitmovin_player_example/pages/custom_html_ui.dart';
import 'package:bitmovin_player_example/pages/drm_playback.dart';
// TODO(mario): rename
import 'package:bitmovin_player_example/pages/licensekey_via_config.dart';

class Home extends StatelessWidget {
  static String routeName = 'Home';
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitmovin Player Demo'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(BasicPlayback.routeName);
              },
              child: const Text('Basic Playback'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(DrmPlayback.routeName);
              },
              child: const Text('DRM Playback'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(BasicPlayerOnly.routeName);
              },
              child: const Text('Basic Playback (Audio only)'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(BasicPlaybackWithEventSubscription.routeName);
              },
              child: const Text('Basic Playback with Event Subscription'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LicenseKeyViaConfig.routeName);
              },
              child: const Text('License key via PlayerConfig'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CustomHtmlUi.routeName);
              },
              child: const Text('Custom HTML UI'),
            ),
          ],
        ),
      ),
    );
  }
}
