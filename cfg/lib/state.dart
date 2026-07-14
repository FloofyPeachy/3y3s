import 'dart:io';

import 'package:a3y3s_cfg/model/plugin.dart';
import 'package:a3y3s_cfg/util.dart';
import 'package:path/path.dart' as p;

Preset currentPreset = Preset(
  name: 'Voltex Nabla Preset',
  description: 'a preset for sdvx nabla..!',
  game: 'sdvx-nb',
  inputSettings: InputSettings(rotation: 90, mirror: false, flip: false),
  demoImage: LaterImg(path: "/home/peachy/3y3s/sdvx-nb/demo.jpg", inputSettings: InputSettings(rotation: 90, mirror: false, flip: false)),
  searchAreas: [
    SearchArea(area: Area(x: 733 / 1080, y: 395 / 1920, width: 48, height:51 ), meaning: .player1Score, characterCount: 4),
    SearchArea(area: Area(x: 923 / 1080, y: 411 / 1920, width: 33, height:36 ), meaning: .player1Score, characterCount: 4)
  ],
  characters: folderToTemplates("/home/peachy/3y3s/sdvx-nb/img/"),
  states: [],

);

List<Template> folderToTemplates(String dir) {
  List<Template> intern = [];
  Directory directory = new Directory(dir);
  for (var file in directory.listSync()) {
    if (file is Directory) continue;
    intern.add(
      Template(
        value: int.parse(p.basenameWithoutExtension(file.path)),
        data: LaterImg(path: file.path),
      ),
    );
  }
  return intern;
}
