
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gta_player/util/preferences.dart';
import 'package:gta_player/widgets/player.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsWidget> {
  bool isLoading = false;

  String? adsPath;
  String? newsPath;
  String? weatherPath;
  List<String>? stationsPath;

  @override
  void initState() {
    adsPath = Preferences.instance.AdsPath;
    newsPath = Preferences.instance.NewsPath;
    weatherPath = Preferences.instance.WeatherPath;
    stationsPath = Preferences.instance.Stations;
  }

  Future<String?> getDir() async {
    if(Platform.isAndroid){
      await FilePicker.platform.clearTemporaryFiles();
    }

    return await FilePicker.platform.getDirectoryPath();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: isLoading ? () async => false : () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Configure Files"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if(adsPath != null && newsPath != null && weatherPath != null && stationsPath != null) ... [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const PlayerWidget()),
                      (_) => false
                    );
                  },
                  child: const Text("Go to player")
                ),
              ],
              ElevatedButton(onPressed: () {
                Preferences.instance.resetPreferences();
                setState(() {
                  adsPath = null;
                  newsPath = null;
                  weatherPath = null;
                  stationsPath = null;
                });
              }, child: const Text("Reset")),
              ElevatedButton(onPressed: () {
                if(adsPath != null){
                  Preferences.instance.resetPreference(Preferences.ADS);
                  setState(() {
                    adsPath = null;
                  });
                  return;
                }
                getDir().then((value) {
                  Preferences.instance.setAdsPath(value!).then((value) {
                    if(value){
                      setState((){
                        adsPath = Preferences.instance.AdsPath;
                      });
                    }
                  });
                });
              }, child: const Text("Ads Folder")),
              Text("Ads Path : $adsPath"),
              ElevatedButton(onPressed: () {
                if(newsPath != null){
                  Preferences.instance.resetPreference(Preferences.NEWS);
                  setState(() {
                    newsPath = null;
                  });
                  return;
                }
                getDir().then((value) {
                  Preferences.instance.setNewsPath(value!).then((value) {
                    if(value){
                      setState((){
                        newsPath = Preferences.instance.NewsPath;
                      });
                    }
                  });
                });
              }, child: const Text("News Folder")),
              Text("News Path : $newsPath"),
              ElevatedButton(onPressed: () {
                if(weatherPath != null){
                  Preferences.instance.resetPreference(Preferences.WEATHER);
                  setState(() {
                    weatherPath = null;
                  });
                  return;
                }

                getDir().then((value) {
                  Preferences.instance.setWeatherPath(value!).then((value) {
                    if(value){
                      setState((){
                        weatherPath = Preferences.instance.WeatherPath;
                      });
                    }
                  });
                });
              }, child: const Text("Weather Folder")),
              Text("Weather Path : $weatherPath"),
              ElevatedButton(onPressed: () {
                /*getDir().then((value) {
                  Preferences.instance.setStations(value!);
                });*/
                getDir().then((dir) {
                  //Get List of dirs here...
                  if(dir == null){
                    return;
                  }
                  final List<String> res = [];
                  final dirs = Directory(dir).listSync();
                  for (var element in dirs) {
                    res.add(element.path);
                  }
                  Preferences.instance.setStations(res).then((value) {
                    if(value){
                      setState((){
                        stationsPath = res;
                      });
                    }
                  });
                });
              }, child: const Text("Stations Folder")),
              Text("Stations Path : $stationsPath"),
            ],
          ),
        ),
      )
    );
  }
}