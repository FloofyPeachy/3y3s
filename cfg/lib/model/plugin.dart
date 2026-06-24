class Template {

}

class InputSettings {
  int rotation;
  bool mirror;
  bool flip;

  InputSettings({required this.rotation, required this.mirror, required this.flip});
}
class Preset {
  String name;
  String description;
  String game;
  List<Template> templates;

  Preset({required this.name, required this.description, required this.game, required this.templates});
}