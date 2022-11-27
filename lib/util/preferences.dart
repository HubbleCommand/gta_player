
import 'dart:async';
import 'dart:io';

import 'package:gta_player/util/station_abstract.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const STATIONS = "stations";
  static const WEATHER = "weather";
  static const ADS = "ads";
  static const NEWS = "news";
  static const STATION = "station";

  List<StationAbstract> getStations() {
    List<StationAbstract> res = [];

    Stations?.forEach((element) {
      String name = File("$element/name.txt").readAsStringSync();
      if(File("$element/SRC.wav").existsSync()) {
        res.add(StationUnsplit(name: name, source: element));
      } else if(Directory("$element/MONO").existsSync()) {
        res.add(StationTalkshow(name: name, source: element));
      } else if(Directory("$element/SONGS").existsSync()) {
        res.add(StationSplit(name: name, source: element));
      }
    });
    
    return res;
  }

  late final SharedPreferences prefs;

  List<String>? get Stations    => prefs.getStringList(STATIONS);
  int?          get Station     => prefs.getInt(STATION);
  String?       get WeatherPath => prefs.getString(WEATHER);
  String?       get AdsPath     => prefs.getString(ADS);
  String?       get NewsPath    => prefs.getString(NEWS);

  Future<bool> setAdsPath(String value) async {
    return await prefs.setString(ADS, value);
  }

  Future<bool> setNewsPath(String value) async {
    return await prefs.setString(NEWS, value);
  }

  Future<bool> setWeatherPath(String value) async {
    return await prefs.setString(WEATHER, value);
  }

  Future<bool> setStations(List<String> value) async {
    return await prefs.setStringList(STATIONS, value);
  }

  Future<bool> setCurrentStation(int value) async {
    return await prefs.setInt(STATION, value);
  }

  Future<bool> resetPreference(String value) async {
    return await prefs.remove(value);
  }

  Future<bool> resetPreferences() async {
    await prefs.remove(ADS);
    await prefs.remove(NEWS);
    await prefs.remove(WEATHER);
    await prefs.remove(STATIONS);
    await prefs.remove(STATION);
    return true;
  }

  //Causes stack overflow
  /*factory Preferences() {
    return _instance;
  }*/

  Future<void> initialize() async {
    return await SharedPreferences.getInstance().then((value) => prefs = value);
  }

  Preferences._internal() {
    //SharedPreferences.getInstance().then((value) => prefs = value);
  }

  static final Preferences _instance = Preferences._internal();

  static Preferences get instance => _instance;
  /*factory Preferences() {
    return _instance;
  }*/
}
