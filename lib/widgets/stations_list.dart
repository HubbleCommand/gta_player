import 'dart:io';
import 'package:flutter/material.dart';
import '../util/station_abstract.dart';

class StationsListWidget extends StatelessWidget {
  final List<StationAbstract> stations;
  const StationsListWidget({super.key, required this.stations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Station"),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: stations.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Image.file(File(stations[index].icon), width: 50, height: 50,),
              title: Text(stations[index].name, overflow: TextOverflow.ellipsis,),
              onTap: () {
                Navigator.pop(context, index);
              },
            );
          }
          ),
        ),
    );
  }
}
