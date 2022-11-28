import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:gta_player/util/file.dart';
import 'package:gta_player/util/preferences.dart';

class AudioMetadata {
  String title;
  String author;

  AudioMetadata({required this.title, required this.author});
}

class Audio {
  String source;
  String title;
  String author;
  Duration? seekAmount;
  Duration? startAt;

  Audio({required this.title, required this.author, required this.source, this.seekAmount, this.startAt});
}

abstract class StationAbstract {
  String name;
  String source;
  late String icon;

  StationAbstract({required this.name, required this.source}){
    icon = "$source/icon.png";
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
  late Duration duration;

  StationUnsplit({required super.name, required super.source}) {
    audioFile = "$source/SRC.wav";
    duration = Duration(seconds: FileUtils.getFileDuration(audioFile).round());
  }

  @override
  Audio next() {
    return Audio(title : "", author : "", source: audioFile, seekAmount: const Duration(seconds: 30));
  }

  @override
  Audio play() {
    return Audio(title : "", author : "", source: audioFile, startAt: Duration(seconds: Random().nextInt(duration.inSeconds)));
  }

  @override
  Audio prev() {
    return Audio(title : "", author : "", source: audioFile, seekAmount: const Duration(seconds: -30));
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
    int selectedID = getRandom(countFiles(directory : "$source/ID/"));
    return "$source/ID/ID_$selectedID.wav";
  }

  String getNews() {
    return "${Preferences.instance.NewsPath}/${getRandom(177)}.wav";
  }

  String getAdvert(){
    return "${Preferences.instance.AdsPath}/${getRandom(165)}.wav";
  }

  String getWeather(){
    if(!supportsWeather) {
      return getNews();
    }
    Weather selectedWeatherType = Weather.values[getRandom(Weather.values.length)];
    int selectedWeather = getRandom(countFiles(directory : "${Preferences.instance.WeatherPath}/${selectedWeatherType.name}/"));
    return "${Preferences.instance.WeatherPath}/$selectedWeatherType/$selectedWeather.wav";
  }

  AudioMetadata getAssetMetadata(String folder, int number){
    //TODO probably just move this to constructor instead of doing this on each read
    final metadataFile = File("$folder/mp3tag.csv");

    if(!metadataFile.existsSync()) {
      return AudioMetadata(title: "", author: "");
    }

    List<String> lineSplit = metadataFile.readAsLinesSync()[number + 1].split(";");

    return AudioMetadata(title: lineSplit[0], author: lineSplit[1]);
  }

  StationSplitAbstract({required super.name, required super.source}){
    supportsWeather = Directory("$source/TO/WEATH").existsSync();
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
      currentlyPlayingIndex = countFiles(directory : "$source/MONO/") - 1 - 1;
    }

    AudioMetadata meta = getAssetMetadata("$source/MONO/", currentlyPlayingIndex);
    return Audio(
      title: meta.title, author: meta.author,
      source: "$source/MONO/$currentlyPlayingIndex.wav"
    );
  }

  @override
  Audio play() {
    if(intermission != null) {
      if(countDown <= 0){
        intermission = null;
        return Audio(title: name, author: "", source: getStationID());
      } else {
        countDown--;

        if(Random().nextBool()) {
          return Audio(title: "NEWS", author: "", source: getNews());
        }
        return Audio(title: "AD BREAK", author: "", source: getAdvert());
      }
    } else {
      //Only play one show between intermissions, immediately configure next intermission
      intermission = Intermission.values[Random().nextInt(Intermission.values.length)];
      countDown = getRandom(10, min: 3);

      currentlyPlayingIndex = getRandom(countFiles(directory : "$source/MONO/") - 1);
      AudioMetadata meta = getAssetMetadata("$source/MONO/", currentlyPlayingIndex);
      return Audio(
        title: meta.title, author: meta.author,
        source: "$source/MONO/$currentlyPlayingIndex.wav"
      );
    }
  }

  @override
  Audio prev() {
    intermission = null;
    currentlyPlayingIndex++;

    //-1 for .csv
    if(currentlyPlayingIndex >= countFiles(directory : "$source/MONO/") - 1 - 1){
      currentlyPlayingIndex = 0;
    }

    AudioMetadata meta = getAssetMetadata("$source/MONO/", currentlyPlayingIndex);
    return Audio(
      title: meta.title, author: meta.author,
      source: "$source/MONO/$currentlyPlayingIndex.wav"
    );
  }
}

class StationSplit extends StationSplitAbstract {
  bool introducingSong = false;

  StationSplit({required super.name, required super.source});

  //TODO handle if no TO anything
  String? getToNews() {
    int count = countFiles(directory : "$source/TO/NEWS/");
    if(count <= 0) {
      return null;
    }
    int selectedTo = getRandom(count) + 1;
    return "$source/TO/NEWS/TNEW_$selectedTo.wav";
  }

  String? getToAdvert() {
    int count = countFiles(directory : "$source/TO/NEWS/");
    if(count <= 0) {
      return null;
    }
    int selectedTo = getRandom(count) + 1;
    return "$source/TO/AD/TAD_$selectedTo.wav";
  }

  String getHostSnippet() {
    int selectedSnippet = getRandom(countFiles(directory : "$source/HOST/"));
    return "$source/HOST/$selectedSnippet.wav";
  }

  //String get

  int countSongIntro(int songNumber) {
    int availableIntros = 0;
    bool hasMoreIntros = false;

    while(hasMoreIntros) {
      hasMoreIntros = File("$source/INTRO/${songNumber}_$availableIntros.wav").existsSync();
      availableIntros++;
    }
    return availableIntros;
  }

  @override
  Audio next() {
    intermission = null;
    currentlyPlayingIndex++;

    //-1 for .csv
    if(currentlyPlayingIndex >= countFiles(directory : "$source/SONGS/") - 1 - 1){
      currentlyPlayingIndex = 0;
    }

    AudioMetadata meta = getAssetMetadata("$source/SONGS", currentlyPlayingIndex);
    return Audio(title: meta.title, author: meta.author, source: "$source/SONGS/$currentlyPlayingIndex.wav");
  }

  @override
  Audio play() {
    if(introducingSong) {
      introducingSong = false;
      countDown--;
      AudioMetadata meta = getAssetMetadata("$source/SONGS", currentlyPlayingIndex);
      return Audio(title: meta.title, author: meta.author, source: "$source/SONGS/$currentlyPlayingIndex.wav");
    } else if (intermission != null) {
      if(countDown < 0) {
        intermission = null;
        return Audio(title: "INTERMISSION OVER", author: "", source: getStationID());
      } else {
        countDown--;

        switch(intermission!) {
          case Intermission.ADS:
            return Audio(title: "AD BREAK", author: "", source: getAdvert());
          case Intermission.NEWS:
            return Audio(title: "NEWS", author: "", source: getNews());
          case Intermission.WEATHER:
            return Audio(title: "NEWS", author: "", source: getWeather());
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
          return Audio(title: "NEWS", author: "", source: toNews ?? getNews());
        } else {
          intermission = Intermission.ADS;
          countDown = getRandom(5, min : 3);
          String? toAds = getToAdvert();
          return Audio(title: "AD BREAK", author: "", source: toAds ?? getAdvert());
        }
      } else {
        //-1 for .csv
        currentlyPlayingIndex = getRandom(countFiles(directory : "$source/SONGS/") - 1);
        introducingSong = true;

        int availableSongIntros = countSongIntro(currentlyPlayingIndex);
        AudioMetadata meta = getAssetMetadata("$source/SONGS", currentlyPlayingIndex);
        if(Random().nextBool() && availableSongIntros > 0) {
          return Audio(
              title: meta.title, author: meta.author,
              source: "$source/INTRO/${currentlyPlayingIndex}_${getRandom(availableSongIntros) + 1}.wav");
        } else {
          return Audio(title: meta.title, author: meta.author, source: getHostSnippet());
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
      currentlyPlayingIndex = countFiles(directory : "$source/SONGS/") - 1 - 1;
    }

    AudioMetadata meta = getAssetMetadata("$source/SONGS", currentlyPlayingIndex);
    return Audio(title: meta.title, author: meta.author, source: "$source/SONGS/$currentlyPlayingIndex.wav");
  }
}
