
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsWidget> {
  bool isLoading = false;


  Future<String?> getDir() async {
    await FilePicker.platform.clearTemporaryFiles();
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
        body: Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: () {

              }, child: const Text("Ads Folder")),
              ElevatedButton(onPressed: () {

              }, child: const Text("News Folder")),
              ElevatedButton(onPressed: () {

              }, child: const Text("Weather Folder")),
              ElevatedButton(onPressed: () {

              }, child: const Text("Add Station")),
              ElevatedButton(onPressed: () {

              }, child: const Text("Add Stations Folder")),
            ],
          ),
        ),
      )
    );
  }
}