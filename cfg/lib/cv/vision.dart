import 'package:a3y3s_cfg/model/plugin.dart';
import 'package:opencv_dart/opencv.dart';
import 'package:image/image.dart' as imd;

class VisionTester {
  final Preset preset;
  Map<(Mat, int), VecPoint> templates = {};
  late Mat demoImage;

  VisionTester(this.preset);

  Future<void> load() async {
    //convert everything into Mats. Since OpenCV works in them, convert them.

    for (var char in preset.characters) {
      var img = await char.data.image();
      var mat = imdecode(imd.encodePng(img), 0);
      var resizedBig = resize(mat, (48, 51), interpolation: INTER_AREA); // Matching C++ dimension limit
      threshold(resizedBig, 0, 255, THRESH_BINARY | THRESH_OTSU);
      var contours = findContours(resizedBig, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

      var contour = bestContour(contours);

      if (contour != null || contour!.isNotEmpty) {
        templates[(mat, char.value)] = contour;
      } else {
       //print("Warning: Template character ${char.name ?? 'unknown'} produced 0 contours!");
        // Option: Handle failure or skip saving it to your matcher template map
      }

    }
    print("Loaded templates.");

    demoImage = imdecode(imd.encodePng(await preset.demoImage.image()), 0);
  }

  VecPoint? bestContour((VecVecPoint, VecVec4i) pointz) {
    final contoursList = pointz.$1;

    // Guard against empty contours
    if (contoursList.isEmpty) {
      return null;
    }

    return contoursList.reduce((c1, c2) {
      return contourArea(c1) > contourArea(c2) ? c1 : c2;
    }).clone();
  }

  void run() {
    var gray = demoImage;
    var bounds = preset.searchAreas[0].area.toRes(1080, 1920);
    for (int i = 0; i < 4; ++i) {
      var mat = gray.region(
        Rect(
          bounds.x.toInt() + (bounds.width.toInt() * i),
          bounds.y.toInt(),
          bounds.width.toInt(),
          bounds.height.toInt(),
        ),
      );

      //gaussianBlur(mat, (3, 3), 0);
      threshold(mat, 0, 255, THRESH_BINARY | THRESH_OTSU);

      var contours = findContours(mat, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
      final liveContour =  bestContour(contours);

      var contour_results = [];
      Map<int, double> scores = {};
      templates.forEach((mat, contour) {
        if (contour.isEmpty) print("contour is empty!");
        double score = matchShapes(
          liveContour!,          // Must be of type cv.VecPoint
          contour,         // Must be of type cv.VecPoint
          CONTOURS_MATCH_I1, // Matching method constant
          0.0,                  // Parameter (always 0)
        );
        scores[mat.$2] = score;
      });
      var sortedMap = Map.fromEntries(
          scores.entries.toList()..sort((a, b) => a.value.compareTo(b.value)) // Low scores (best matches) first
      );

      print("num is: " + sortedMap.keys.first.toString());
    }
  }
}
