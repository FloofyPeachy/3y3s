import 'package:a3y3s_cfg/model/plugin.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
double dH(BuildContext context) => MediaQuery.of(context).size.height;
double dW(BuildContext context) => MediaQuery.of(context).size.width;
TextStyle fGStandard = TextStyle(
  fontFamily: "Franklin Gothic",
  //fontSize: 64,
  height: 0.7,
  color: Colors.white,
);

TextStyle fgStandardSize(double fontSize) {
  return fGStandard.copyWith(fontSize: fontSize);
}

TextTheme ts(BuildContext context) => Theme.of(context).textTheme;

class LaterImg {
  img.Image? data;
  String path;
  InputSettings? inputSettings;

  LaterImg({this.data, required this.path, this.inputSettings});

  Future<img.Image> image() async {

    if (inputSettings != null) {
      final cmd = img.Command()
          ..decodeImageFile(path)
          ..copyRotate(angle: inputSettings!.rotation);
      await cmd.executeThread();
      data ??= cmd.outputImage!;

    } else {
      data ??= await img.decodeImageFile(path);
    }
    return Future.value(data);
  }
}