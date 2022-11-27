import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gta_player/util/globals.dart';
import 'package:gta_player/util/preferences.dart';
import 'package:gta_player/util/station_abstract.dart';
import 'package:gta_player/widgets/settings.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GTA Radio'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<StationAbstract> stationsInstanced = [
    //GTA V Stations
    StationSplit(name: "Los Santos Rock Radio", source: "01_CROCK"),
    StationSplit(name: "Non Stop Pop", source: "02_POP"),
    StationSplit(name: "Radio Los Santos", source: "03_HH_N"),
    StationSplit(name: "Channel X", source: "04_PUNK"),
    StationTalkshow(name: "West Coast Talk Radio", source: "05_T1"),
    StationSplit(name: "Rebel Radio", source: "06_CUNT"),
    StationUnsplit(name: "Soulwax FM", source: "07_DAN1"),
    StationUnsplit(name: "East Los FM", source: "08_MEX"),
    StationSplit(name: "West Coast Classics", source: "09_HH_O"),
    StationTalkshow(name: "Blaine County Radio", source: "11_T2"),
    StationSplit(name: "Blue Ark FM", source: "12_REGG"),
    StationUnsplit(name: "WorldWide FM", source: "13_JAZZ"),
    StationUnsplit(name: "FlyLo FM", source: "14_DAN2"),
    StationSplit(name: "Low Down", source: "15_MTWN"),
    StationSplit(name: "Radio Mirror Park", source: "16_SILK"),
    StationSplit(name: "Space", source: "17_FUNK"),
    StationSplit(name: "Vinewood Boulevard Radio", source: "18_90RK"),

    //GTA IV Stations
    StationSplit(name: "International Funk 99", source: "A_AFRO"),
    StationSplit(name: "Tuff Gong Radio", source: "B_BBYLN"),
    StationUnsplit(name: "The Beat 102.7", source: "C_BEAT"),
    StationUnsplit(name: "Massive B Soundsystem 96.9", source: "D_BK"),
    StationSplit(name: "The Journey", source: "E_CLASS",),  //NO TO
    StationUnsplit(name: "Electro-Choc", source: "F_DANM"),
    StationSplit(name: "Radio Brocker", source: "G_DANR"),
    //WTF 8? Just extra songs?
    StationSplit(name: "Fusion FM", source: "H_FUS"),
    StationSplit(name: "Liberty City Hard Core", source: "I_HARD"),
    //!,!! CHANNEL 11 WAS MEANT FOR A USER-MADE RADIO STATION ON PC VERSIONS OF GTA IV !!!
    StationSplit(name: "Jazz Nation Radio 108.5", source: "J_JAZZ"),
    StationSplit(name: "K109 The Studio", source: "K_K109"),
    StationTalkshow(name: "Integrity 2.0", source: "L_LZLW"),
    StationSplit(name: "Liberty Rock Radio", source: "M_LIBR"),
    StationSplit(name: "Self-Actualization FM", source: "N_MED"),  //NO TO
    StationUnsplit(name: "The Classics 104.1", source: "O_NYCL"),
    StationTalkshow(name: "Public Liberty Radio", source: "P_PLR"),
    StationUnsplit(name: "RamJam FM", source: "Q_RJFM"), //TODO get icon
    StationSplit(name: "San Juan Sounds", source: "R_SJS"),
    StationSplit(name: "The Vibe 98.8", source: "S_VIBE"),
    StationSplit(name: "Vice City FM", source: "T_VCFM"),  //TODO get icon
    StationSplit(name: "Vladivostok FM", source: "U_VLAD"),
    StationTalkshow(name: "WKTT Radio", source: "V_WKTT"),
  ];

/*
  List<StationAbstract> stationsInstanced = [
    //GTA V Stations
    StationSplit(name: "Los Santos Rock Radio", source: "01_CROCK", icon: "Los Santos Rock Radio.png"),
    StationSplit(name: "Non Stop Pop", source: "02_POP", icon: "Non Stop Pop.png"),
    StationSplit(name: "Radio Los Santos", source: "03_HH_N", icon: "Radio Los Santos.png"),
    StationSplit(name: "Channel X", source: "04_PUNK", icon: "Channel X.png"),
    StationTalkshow(name: "West Coast Talk Radio", source: "05_T1", icon: "WCTR.png"),
    StationSplit(name: "Rebel Radio", source: "06_CUNT", icon: "Rebel Radio.png"),
    StationUnsplit(name: "Soulwax FM", source: "07_DAN1", icon: "Soulwax FM.png"),
    StationUnsplit(name: "East Los FM", source: "08_MEX", icon: "East Los.png"),
    StationSplit(name: "West Coast Classics", source: "09_HH_O", icon: "West Coast Classics.png"),
    StationTalkshow(name: "Blaine County Radio", source: "11_T2", icon: "Blaine County Radio.png"),
    StationSplit(name: "Blue Ark FM", source: "12_REGG", icon: "Blue Ark.png"),
    StationUnsplit(name: "WorldWide FM", source: "13_JAZZ", icon: "WorldWide FM.png"),
    StationUnsplit(name: "FlyLo FM", source: "14_DAN2", icon: "FlyLo.png"),
    StationSplit(name: "Low Down", source: "15_MTWN", icon: "Low Down.png"),
    StationSplit(name: "Radio Mirror Park", source: "16_SILK", icon: "Radio Mirror Park.png"),
    StationSplit(name: "Space", source: "17_FUNK", icon: "Space.png"),
    StationSplit(name: "Vinewood Boulevard Radio", source: "18_90RK", icon: "Vinewood Boulevard Radio.png"),

    //GTA IV Stations
    StationSplit(name: "International Funk 99", source: "A_AFRO", icon: "if99_bw.png"),
    StationSplit(name: "Tuff Gong Radio", source: "B_BBYLN", icon: "tuffgong_bw.png"),
    StationUnsplit(name: "The Beat 102.7", source: "C_BEAT", icon: "beat_bw.png"),
    StationUnsplit(name: "Massive B Soundsystem 96.9", source: "D_BK", icon: "massiveb_bw.png"),
    StationSplit(name: "The Journey", source: "E_CLASS", icon: "thejourney_bw.png"),  //NO TO
    StationUnsplit(name: "Electro-Choc", source: "F_DANM", icon: "electrochoc_bw.png"),
    StationSplit(name: "Radio Brocker", source: "G_DANR", icon: "radiobroker_bw.png"),
    //WTF 8? Just extra songs?
    StationSplit(name: "Fusion FM", source: "H_FUS", icon: "fusion_bw.png"),
    StationSplit(name: "Liberty City Hard Core", source: "I_HARD", icon: "lchc_bw.png"),
    //!,!! CHANNEL 11 WAS MEANT FOR A USER-MADE RADIO STATION ON PC VERSIONS OF GTA IV !!!
    StationSplit(name: "Jazz Nation Radio 108.5", source: "J_JAZZ", icon: "jnr_bw.png"),
    StationSplit(name: "K109 The Studio", source: "K_K109", icon: "k109_bw.png"),
    StationTalkshow(name: "Integrity 2.0", source: "L_LZLW", icon: "integrity_bw.png"),
    StationSplit(name: "Liberty Rock Radio", source: "M_LIBR", icon: "lrr_bw.png"),
    StationSplit(name: "Self-Actualization FM", source: "N_MED", icon: "self-actu.png"),  //NO TO
    StationUnsplit(name: "The Classics 104.1", source: "O_NYCL", icon: "theclassics_bw.png"),
    StationTalkshow(name: "Public Liberty Radio", source: "P_PLR", icon: "plr_bw.png"),
    StationUnsplit(name: "RamJam FM", source: "Q_RJFM", icon: "NONE SELECTED.png"), //TODO get icon
    StationSplit(name: "San Juan Sounds", source: "R_SJS", icon: "sanjuan_bw.png"),
    StationSplit(name: "The Vibe 98.8", source: "S_VIBE", icon: "thevibe_bw.png"),
    StationSplit(name: "Vice City FM", source: "T_VCFM", icon: "NONE SELECTED.png"),  //TODO get icon
    StationSplit(name: "Vladivostok FM", source: "U_VLAD", icon: "vladivostok_bw.png"),
    StationTalkshow(name: "WKTT Radio", source: "V_WKTT", icon: "wktt_bw.png"),
  ];

  final stations = const [
    //GTA V Stations
    {"type" : 1, "name" : "Los Santos Rock Radio",      "src" : "01_CROCK", "icon" : "Los Santos Rock Radio.png"},
    {"type" : 1, "name" : "Non Stop Pop",               "src" : "02_POP",   "icon" : "Non Stop Pop.png"},
    {"type" : 1, "name" : "Radio Los Santos",           "src" : "03_HH_N",  "icon" : "Radio Los Santos.png"},
    {"type" : 1, "name" : "Channel X",                  "src" : "04_PUNK",  "icon" : "Channel X.png"},
    {"type" : 2, "name" : "West Coast Talk Radio",      "src" : "05_T1",    "icon" : "WCTR.png"},
    {"type" : 1, "name" : "Rebel Radio",                "src" : "06_CUNT",  "icon" : "Rebel Radio.png"},
    {"type" : 0, "name" : "Soulwax FM",                 "src" : "07_DAN1",  "icon" : "Soulwax FM.png"},
    {"type" : 0, "name" : "East Los FM",                "src" : "08_MEX",   "icon" : "East Los.png"},
    {"type" : 1, "name" : "West Coast Classics",        "src" : "09_HH_O",  "icon" : "West Coast Classics.png"},
    {"type" : 2, "name" : "Blaine County Radio",        "src" : "11_T2",    "icon" : "Blaine County Radio.png"},
    {"type" : 1, "name" : "Blue Ark FM",                "src" : "12_REGG",  "icon" : "Blue Ark.png"},
    {"type" : 0, "name" : "WorldWide FM",               "src" : "13_JAZZ",  "icon" : "WorldWide FM.png"},
    {"type" : 0, "name" : "FlyLo FM",                   "src" : "14_DAN2",  "icon" : "FlyLo.png"},
    {"type" : 1, "name" : "Low Down",                   "src" : "15_MTWN",  "icon" : "Low Down.png"},
    {"type" : 1, "name" : "Radio Mirror Park",          "src" : "16_SILK",  "icon" : "Radio Mirror Park.png"},
    {"type" : 1, "name" : "Space",                      "src" : "17_FUNK",  "icon" : "Space.png"},
    {"type" : 1, "name" : "Vinewood Boulevard Radio",   "src" : "18_90RK",  "icon" : "Vinewood Boulevard Radio.png"},

    //GTA IV Stations
    {"type" : 1, "name" : "International Funk 99",      "src" : "A_AFRO",   "icon" : "if99_bw.png"},
    {"type" : 1, "name" : "Tuff Gong Radio",            "src" : "B_BBYLN",  "icon" : "tuffgong_bw.png"},
    {"type" : 0, "name" : "The Beat 102.7",             "src" : "C_BEAT",   "icon" : "beat_bw.png"},
    {"type" : 0, "name" : "Massive B Soundsystem 96.9", "src" : "D_BK",     "icon" : "massiveb_bw.png"},
    {"type" : 1, "name" : "The Journey",                "src" : "E_CLASS",  "icon" : "thejourney_bw.png"},
    {"type" : 0, "name" : "Electro-Choc",               "src" : "F_DANM",   "icon" : "electrochoc_bw.png"},
    {"type" : 1, "name" : "Radio Brocker",              "src" : "G_DANR",   "icon" : "radiobroker_bw.png"},
    //WTF 8? Just extra songs?
    {"type" : 1, "name" : "Fusion FM",                  "src" : "H_FUS",    "icon" : "fusion_bw.png"},
    {"type" : 1, "name" : "Liberty City Hard Core",     "src" : "I_HARD",   "icon" : "lchc_bw.png"},
    //!,!! CHANNEL 11 WAS MEANT FOR A USER-MADE RADIO STATION ON PC VERSIONS OF GTA IV !!!
    {"type" : 1, "name" : "Jazz Nation Radio 108.5",    "src" : "J_JAZZ",   "icon" : "jnr_bw.png"},
    {"type" : 1, "name" : "K109 The Studio",            "src" : "K_K109",   "icon" : "k109_bw.png"},
    {"type" : 2, "name" : "Integrity 2.0",              "src" : "L_LZLW",   "icon" : "integrity_bw.png"},
    {"type" : 1, "name" : "Liberty Rock Radio",         "src" : "M_LIBR",   "icon" : "lrr_bw.png"},
    {"type" : 1, "name" : "Self-Actualization FM",      "src" : "N_MED",    "icon" : "self-actu.png"},
    {"type" : 0, "name" : "The Classics 104.1",         "src" : "O_NYCL",   "icon" : "theclassics_bw.png"},
    {"type" : 2, "name" : "Public Liberty Radio",       "src" : "P_PLR",    "icon" : "plr_bw.png"},
    {"type" : 0, "name" : "RamJam FM",                  "src" : "Q_RJFM",   "icon" : "NONE SELECTED.png"}, //TODO get icon
    {"type" : 1, "name" : "San Juan Sounds",            "src" : "R_SJS",    "icon" : "sanjuan_bw.png"},
    {"type" : 1, "name" : "The Vibe 98.8",              "src" : "S_VIBE",   "icon" : "thevibe_bw.png"},
    {"type" : 1, "name" : "Vice City FM",               "src" : "T_VCFM",   "icon" : "NONE SELECTED.png"}, //TODO get icon
    {"type" : 1, "name" : "Vladivostok FM",             "src" : "U_VLAD",   "icon" : "vladivostok_bw.png"},
    {"type" : 2, "name" : "WKTT Radio",                 "src" : "V_WKTT",   "icon" : "wktt_bw.png"},
  ];
*/

  final player = AudioPlayer();
  //final preferences = Preferences();
  int selectedStation = 6;

  @override
  void initState() {
    super.initState();
    Preferences();

    Permission.storage.status.then((value) {
      if (value != PermissionStatus.granted || value != PermissionStatus.limited) {
        Permission.storage.request().then((value){
          Permission.storage.status.then((valueInner) {
            if (valueInner != PermissionStatus.granted || value != PermissionStatus.limited) {
              Permission.manageExternalStorage.request().then((valueInner){
                debugPrint("Storage : ${value} External storage : ${valueInner}");
              });
            }
          });
        });
      }
    });

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
  }

  final ValueNotifier<bool> _playingNotifier = ValueNotifier(false);
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(const Duration(seconds: 0));
  final ValueNotifier<String> _nameNotifier = ValueNotifier("");
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

  void play(Audio asset) {
    player.stop();
    player.dispose();

    try {
      _nameNotifier.value = asset.name;
      player.play(DeviceFileSource(asset.source));

      if(asset.startFrom != null) {
        _seek(asset.startFrom!, false);
      }
    } catch (e) {
      _nameNotifier.value = "ERROR LOADING FILE";
      player.stop();
      player.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Spacer(),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.settings, size: 18.0),
                onPressed: () {
                  //debugPrint("CLICKED");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsWidget()),
                  );
                }
              )
            ],
          ),
          Expanded(child: StationCard(station: stationsInstanced[selectedStation])),
          ValueListenableBuilder(valueListenable: _nameNotifier, builder: (BuildContext context, String value, Widget? child) {
            return Text(value);
          }),
          Row(
            children: [
              ValueListenableBuilder(valueListenable: _positionNotifier, builder: (BuildContext context, Duration value, Widget? child) {
                return Text(formatTime(value.inSeconds));
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
              Text(formatTime(_duration.inSeconds))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //TODO if want full vertical button
              /*ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedStation = selectedStation - 1 <= 0 ? stationsInstanced.length - 1 : selectedStation - 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const <Widget>[
                    /*Icon(Icons.developer_board),
                    SizedBox(height: 10),
                    Text("Experiences"),*/
                    const Icon(Icons.arrow_left, size: 18.0),
                  ],
                ),
              ),*/
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.skip_previous, size: 18.0),
                onPressed: () {
                  setState(() {
                    player.stop();
                    selectedStation = selectedStation - 1 <= 0 ? stationsInstanced.length - 1 : selectedStation - 1;
                    play(stationsInstanced[selectedStation].play());
                  });
                },
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                icon: const Icon(Icons.fast_rewind, size: 18.0),
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
                  icon: Icon(_playingNotifier.value ? Icons.pause : Icons.play_arrow),
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
                icon: const Icon(Icons.fast_forward, size: 18.0),
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
                icon: const Icon(Icons.skip_next, size: 18.0),
                onPressed: () {
                  setState(() {
                    player.stop();
                    selectedStation = selectedStation + 1 >= stationsInstanced.length - 1 ? 0 : selectedStation + 1;
                    play(stationsInstanced[selectedStation].play());
                  });
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
  StationAbstract station;

  StationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.file(File(station.icon), height: 150, width: 150, /*fit: BoxFit.fitWidth,*/),
      Text("${station.name} - ${station.runtimeType}"),
    ]);
  }
}
