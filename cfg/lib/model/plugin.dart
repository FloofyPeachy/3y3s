
import 'package:a3y3s_cfg/util.dart';
import 'package:image/image.dart' as img;
class Template {
  int value;
  LaterImg data;

  Template({required this.value, required this.data});
}

enum Meaning {
  player1Score,
  player2Score,

}

class InputSettings {
  int rotation;
  bool mirror;
  bool flip;

  InputSettings({required this.rotation, required this.mirror, required this.flip});
}

class Area {
  num x,y,width,height;
  Area({required this.x, required this.y, required this.width, required this.height});

  Area toRes(int wWidth, int hHeight) {
    return Area(
      x: (x * wWidth).floor(),
      y: (y * hHeight).floor(),
      width: width.round(),
      height: height.round(),
    );
  }
}
class SearchArea {
  Area area;
  Meaning meaning;
  int characterCount;
  SearchArea({required this.area, required this.meaning, required this.characterCount});
}

class Preset {
  String name;
  String description;
  String game;
  InputSettings inputSettings;
  List<Template> characters;
  List<Template> states;
  List<SearchArea> searchAreas;
  LaterImg demoImage;

  Preset({required this.name, required this.description, required this.inputSettings, required this.game, required this.characters, required this.states, required this.demoImage, required this.searchAreas});
}