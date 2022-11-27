import 'package:flutter/material.dart';
import 'package:gta_player/util/preferences.dart';
import 'package:gta_player/widgets/player.dart';
import 'package:gta_player/widgets/settings.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingState();
}

class _LoadingState extends State<LoadingWidget> {

  @override
  void initState() {
    super.initState();
    Preferences.instance.initialize().then((value) {
      //TODO first, we initialize preferences, then load stations? Or is just this enough
      //ACTUALLY check if necessary things have boon configured, otherwise send to settings!

      Widget destination = const PlayerWidget();
      if(Preferences.instance.Stations == null || Preferences.instance.AdsPath == null || Preferences.instance.NewsPath == null) {
        destination = const SettingsWidget();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => destination),
        (_) => false
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
