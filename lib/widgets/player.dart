import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gta_player/util/preferences.dart';
import 'package:gta_player/util/station_abstract.dart';
import 'package:gta_player/widgets/settings.dart';
import 'package:gta_player/widgets/stations_list.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerState();
}

class _PlayerState extends State<PlayerWidget> {
  List<StationAbstract> stationsInstanced = [];
  final player = AudioPlayer();
  int selectedStation = 0;

  @override
  void initState() {
    super.initState();

    stationsInstanced = Preferences.instance.getStations();
    selectedStation = Preferences.instance.Station ?? selectedStation;

    player.onPlayerComplete.listen((event) {
      //Play next
      debugPrint("Player completed...");
      play(stationsInstanced[selectedStation].play());
    });
    player.onPlayerStateChanged.listen((event) {
      debugPrint(event.toString());
      _playingNotifier.value = event == PlayerState.playing;
    });
    player.onPositionChanged.listen((event) {
      _positionNotifier.value = event;
    });
    player.onDurationChanged.listen((event) {
      setState(() {
        _duration = event;
      });
    });

    play(stationsInstanced[selectedStation].play());
  }

  final ValueNotifier<bool> _playingNotifier = ValueNotifier(false);
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(const Duration(seconds: 0));
  final ValueNotifier<String> _titleNotifier = ValueNotifier("");
  final ValueNotifier<String> _authorNotifier = ValueNotifier("");
  Duration _duration = const Duration(seconds: 0);

  void _seek(Duration duration, bool startFromCurrentPosition) {
    if(!startFromCurrentPosition) {
      player.seek(duration);
      return;
    }

    player.getCurrentPosition().then((value) => {
      player.seek(duration + value!)
    });
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  void playStation(int index) {
    setState(() {
      player.stop();
      selectedStation = index;
      Preferences.instance.setCurrentStation(index);
      play(stationsInstanced[index].play());
    });
  }

  void play(Audio asset) {
    player.stop();
    player.dispose();

    try {
      _titleNotifier.value = asset.title;
      _authorNotifier.value = asset.author;
      player.play(DeviceFileSource(asset.source));

      if(asset.seekAmount != null) {
        _seek(asset.seekAmount! + _positionNotifier.value, true);
      }
      if(asset.startAt != null) {
        _seek(asset.startAt!, false);
      }
    } catch (e) {
      _titleNotifier.value = "ERROR LOADING FILE";
      _authorNotifier.value = "";
      player.stop();
      player.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.view_list, size: 18.0, color: Colors.white,),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StationsListWidget(stations: stationsInstanced,)),
                  );

                  if (!mounted || result == null) return;

                  if(result.runtimeType == int) {
                    if(result > 0 && result < stationsInstanced.length - 1) {
                      playStation(result);
                      return;
                    }
                  }

                  //If the selected station couldn't be found
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text("Couldn't find the selected station")));
                }
              ),
              const Spacer(),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.settings, size: 18.0, color: Colors.white,),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsWidget()),
                  );
                }
              )
            ],
          ),
          Expanded(child: StationCard(station: stationsInstanced[selectedStation])),
          ValueListenableBuilder(valueListenable: _titleNotifier, builder: (BuildContext context, String value, Widget? child) {
            return Visibility(
              visible: value.isNotEmpty,
              child: Text(value, style: const TextStyle(fontFamily: 'SevenSegment', color: Colors.white),)
            );
          }),
          ValueListenableBuilder(valueListenable: _authorNotifier, builder: (BuildContext context, String value, Widget? child) {
            return Visibility(
              visible: value.isNotEmpty,
              child: Text(value, style: const TextStyle(fontFamily: 'SevenSegment', color: Colors.white),)
            );
          }),
          Row(
            children: [
              ValueListenableBuilder(valueListenable: _positionNotifier, builder: (BuildContext context, Duration value, Widget? child) {
                return Text(formatTime(value.inSeconds), style: const TextStyle(fontFamily: 'SevenSegment', color: Colors.white));
              }),
              Expanded(
                child: ValueListenableBuilder(valueListenable: _positionNotifier, builder: (BuildContext context, Duration value, Widget? child) {
                  return Slider(
                    min: 0,
                    max: _duration.inMilliseconds.toDouble(),
                    value: value.inMilliseconds.toDouble(),
                    onChanged: (changedValue) {
                      _seek(Duration(milliseconds: changedValue.toInt()), false);
                    },
                  );
                }),
              ),
              Text(formatTime(_duration.inSeconds), style: const TextStyle(fontFamily: 'SevenSegment', color: Colors.white))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.skip_previous, size: 18.0, color: Colors.white,),
                onPressed: () {
                  playStation(selectedStation - 1 <= 0 ? stationsInstanced.length - 1 : selectedStation - 1);
                },
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.fast_rewind, size: 18.0, color: Colors.white,),
                onPressed: () {
                  setState(() {
                    play(stationsInstanced[selectedStation].prev());
                  });
                },
              ),
              ValueListenableBuilder(valueListenable: _playingNotifier, builder: (BuildContext context, bool value, Widget? child) {
                return IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: Icon(_playingNotifier.value ? Icons.pause : Icons.play_arrow, color: Colors.white,),
                  onPressed: () {
                    _playingNotifier.value = !_playingNotifier.value;
                    if(_playingNotifier.value) {
                      player.resume();
                    } else {
                      player.pause();
                    }
                  },
                );
              }),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.fast_forward, size: 18.0, color: Colors.white,),
                onPressed: () {
                  setState(() {
                    play(stationsInstanced[selectedStation].next());
                  });
                },
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.skip_next, size: 18.0, color: Colors.white,),
                onPressed: () {
                  playStation(selectedStation + 1 >= stationsInstanced.length - 1 ? 0 : selectedStation + 1);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();

    super.dispose();
  }
}

class StationCard extends StatelessWidget {
  final StationAbstract station;

  const StationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(child: Image.file(File(station.icon), fit: BoxFit.contain),),
      FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(station.name, style : const TextStyle(fontFamily: 'Pricedown', color: Colors.white),),
      ),
    ]);
  }
}
