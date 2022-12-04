import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gta_player/widgets/loading.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Permission.storage.status.then((value) {
      if (value != PermissionStatus.granted) {
        Permission.storage.request().then((value){
          Permission.manageExternalStorage.status.then((valueInner) {
            if (valueInner != PermissionStatus.granted) {
              Permission.manageExternalStorage.request().then((valueInner){
                debugPrint("Storage : ${value} External storage : ${valueInner}");
              });
            }
          });
        });
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoadingWidget(),
    );
  }
}
