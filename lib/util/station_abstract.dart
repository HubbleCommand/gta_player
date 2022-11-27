import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:gta_player/util/globals.dart';
import 'package:gta_player/util/preferences.dart';


class Audio {
  String source;
  String name;
  Duration? startFrom;

  Audio({required this.name, required this.source, this.startFrom});
}

abstract class StationAbstract {
  String name;
  String source;
  late String icon;
  StationAbstract({required this.name, required this.source}){
    icon = "assets/gta_player_audio/$source/icon.png"; //"${GLOBALS.ICONS_PATH}${station.icon}"
    if(!File(icon).existsSync()){
      icon = "assets/missing_icon.png";
    }
  }

  Audio play();
  Audio next();
  Audio prev();

  //TODO also change cpp version to pass back the source to play!
  // So that we don't get circular dependencies

  int getRandom(int max, {int min = 0}){
    return min + Random().nextInt(max - min);
  }

  int countFiles({String? directory, String? extension}) {
    if(directory != null){
      try {
        debugPrint("Files : ${Directory(directory).listSync().length}");
        return Directory(directory).listSync().length;
      } catch (e) {
        return 0;
      }
    }
    return Directory(source).listSync().length;
  }
}

class StationUnsplit extends StationAbstract {
  late String audioFile;

  StationUnsplit({required super.name, required super.source}) {
    audioFile = "assets/gta_player_audio/$source/SRC.wav";
  }

  @override
  Audio next() {
    //TODO something with skipping...
    return Audio(name : "", source: audioFile);
  }

  @override
  Audio play() {
    return Audio(name : "", source: audioFile);
  }

  @override
  Audio prev() {
    return Audio(name : "", source: audioFile);
  }
}

enum Weather { CLOUD, FOG, RAIN, SUN, WIND }
enum Intermission { ADS, NEWS, WEATHER }

abstract class StationSplitAbstract extends StationAbstract {
  int countDown = 0;
  Intermission? intermission;
  bool supportsWeather = false;
  int currentlyPlayingIndex = 0;

  String getStationID() {
    int selectedID = getRandom(countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/ID/"));
    return "${GLOBALS.AUDIO_PATH}$source/ID/ID_$selectedID.wav";
  }

  String getNews() {
    return "${GLOBALS.NEWS_PATH}${getRandom(177)}.wav";
  }

  String getAdvert(){
    //Preferences().NewsPath;
    //return "${GLOBALS.ADS_PATH}${getRandom(165)}.wav";
    return "${Preferences().AdsPath}${getRandom(165)}.wav";
  }

  String getWeather(){
    if(!supportsWeather) {
      return getNews();
    }
    Weather selectedWeatherType = Weather.values[getRandom(Weather.values.length)];
    int selectedWeather = getRandom(countFiles(directory : "/assets/gta_player_audio/WEATHER/${selectedWeatherType.name}/"));
    return "/assets/gta_player_audio/WEATHER/$selectedWeatherType/$selectedWeather.wav";
  }

  String getAssetMetadata(String folder, int number){
    //TODO probably just move this to constructor instead of doing this on each read
    final metadataFile = File("$folder/mp3tag.csv");

    if(!metadataFile.existsSync()) {
      return "";
    }

    return metadataFile.readAsLinesSync()[number + 1].split(";")[0];
  }

  StationSplitAbstract({required super.name, required super.source}){
    supportsWeather = Directory("${GLOBALS.AUDIO_PATH}$source/WEATH").existsSync();
  }
}

class StationTalkshow extends StationSplitAbstract {
  StationTalkshow({required super.name, required super.source}) {
    supportsWeather = true;
  }

  @override
  Audio next() {
    intermission = null;
    currentlyPlayingIndex--;

    if(currentlyPlayingIndex < 0){
      //-1 for .csv
      currentlyPlayingIndex = countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/MONO/") - 1 - 1;
    }

    return Audio(
      name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/MONO/", currentlyPlayingIndex),
      source: "${GLOBALS.AUDIO_PATH}$source/MONO/$currentlyPlayingIndex.wav"
    );
  }

  @override
  Audio play() {
    if(intermission != null) {
      if(countDown <= 0){
        intermission = null;
        return Audio(name: name, source: getStationID());
      } else {
        countDown--;

        if(Random().nextBool()) {
          return Audio(name: "NEWS", source: getNews());
        }
        return Audio(name: "AD BREAK", source: getAdvert());
      }
    } else {
      countDown = getRandom(10, min: 3);

      currentlyPlayingIndex = getRandom(countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/MONO/") - 1);
      return Audio(
        name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/MONO/", currentlyPlayingIndex),
        source: "${GLOBALS.AUDIO_PATH}$source/MONO/$currentlyPlayingIndex.wav"
      );
    }
  }

  @override
  Audio prev() {
    intermission = null;
    currentlyPlayingIndex++;

    //-1 for .csv
    if(currentlyPlayingIndex >= countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/MONO/") - 1 - 1){
      currentlyPlayingIndex = 0;
    }

    return Audio(
      name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/MONO/", currentlyPlayingIndex),
      source: "${GLOBALS.AUDIO_PATH}$source/MONO/$currentlyPlayingIndex.wav"
    );
  }
}

class StationSplit extends StationSplitAbstract {
  bool introducingSong = false;

  StationSplit({required super.name, required super.source});

  //TODO handle if no TO anything
  String? getToNews() {
    int count = countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/TO/NEWS/");
    if(count <= 0) {
      return null;
    }
    int selectedTo = getRandom(count);
    return "${GLOBALS.AUDIO_PATH}$source/TO/NEWS/TNEW_$selectedTo.wav";
  }

  String? getToAdvert() {
    //int selectedTo = getRandom(countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/TO/AD/"));
    int count = countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/TO/NEWS/");
    if(count <= 0) {
      return null;
    }
    int selectedTo = getRandom(count);
    return "${GLOBALS.AUDIO_PATH}$source/TO/AD/TAD_$selectedTo.wav";
  }

  String getHostSnippet() {
    int selectedSnippet = getRandom(countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/HOST/"));
    return "${GLOBALS.AUDIO_PATH}$source/HOST/$selectedSnippet.wav";
  }

  //String get

  int countSongIntro(int songNumber) {
    int availableIntros = 0;
    bool hasMoreIntros = false;
    
    while(hasMoreIntros) {
      hasMoreIntros = File("${GLOBALS.AUDIO_PATH}$source/INTRO/${songNumber}_$availableIntros.wav").existsSync();
      availableIntros++;
    }
    return availableIntros;
  }

  @override
  Audio next() {
    intermission = null;
    currentlyPlayingIndex++;

    //-1 for .csv
    if(currentlyPlayingIndex >= countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/SONGS/") - 1 - 1){
      currentlyPlayingIndex = 0;
    }

    return Audio(name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/SONGS", currentlyPlayingIndex), source: "${GLOBALS.AUDIO_PATH}$source/SONGS/$currentlyPlayingIndex.wav");
  }

  @override
  Audio play() {
    if(introducingSong) {
      introducingSong = false;
      countDown--;
      return Audio(name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/SONGS", currentlyPlayingIndex), source: "${GLOBALS.AUDIO_PATH}$source/SONGS/$currentlyPlayingIndex.wav");
    } else if (intermission != null) {
      if(countDown < 0) {
        intermission = null;
        return Audio(name: "INTERMISSION OVER", source: getStationID());
      } else {
        countDown--;

        switch(intermission!) {
          case Intermission.ADS:
            return Audio(name: "AD BREAK", source: getAdvert());
          case Intermission.NEWS:
            return Audio(name: "NEWS", source: getNews());
          case Intermission.WEATHER:
            return Audio(name: "NEWS", source: getWeather());
        }
      }
    } else {
      if(countDown < 0) {
        //TODO support weather for stations that support it
        //intermission = Intermission.values[Random().nextInt(Intermission.values.length)];

        if(Random().nextBool()) {
          intermission = Intermission.NEWS;
          countDown = getRandom(5, min : 3);
          String? toNews = getToNews();
          return Audio(name: "NEWS", source: toNews ?? getNews());
        } else {
          intermission = Intermission.ADS;
          countDown = getRandom(5, min : 3);
          String? toAds = getToAdvert();
          return Audio(name: "AD BREAK", source: toAds ?? getAdvert());
        }
      } else {
        //-1 for .csv
        currentlyPlayingIndex = getRandom(countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/SONGS/") - 1);
        introducingSong = true;

        int availableSongIntros = countSongIntro(currentlyPlayingIndex);
        if(Random().nextBool() && availableSongIntros > 0) {
          return Audio(
              name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/SONGS", currentlyPlayingIndex),
              source: "${GLOBALS.AUDIO_PATH}$source/INTRO/${currentlyPlayingIndex}_${getRandom(availableSongIntros) + 1}.wav");
        } else {
          return Audio(name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/SONGS", currentlyPlayingIndex), source: getHostSnippet());
        }
      }
    }
  }

  @override
  Audio prev() {
    intermission = null;
    currentlyPlayingIndex--;

    if(currentlyPlayingIndex < 0){
      //-1 for .csv
      currentlyPlayingIndex = countFiles(directory : "${GLOBALS.AUDIO_PATH}$source/SONGS/") - 1 - 1;
    }

    return Audio(name: getAssetMetadata("${GLOBALS.AUDIO_PATH}$source/SONGS", currentlyPlayingIndex), source: "${GLOBALS.AUDIO_PATH}$source/SONGS/$currentlyPlayingIndex.wav");
  }
}
