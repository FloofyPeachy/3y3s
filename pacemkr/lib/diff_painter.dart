import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show NumberFormat;

class DiffPainter extends CustomPainter {
  final num p1Score;
  final num p2Score;

  DiffPainter({super.repaint, required this.p1Score, required this.p2Score});

  double mR(double total, double multiplier) => total * multiplier;
  double fr() {

    if (p1Score == p2Score) {
      return 0.5;
    }

    double diff = (p1Score - p2Score).toDouble();
    double normDiff = (diff / 1000000).clamp(-1.0, 1.0);

    return 0.5 + (normDiff * 0.5);
  }

  int roundToNearestThousand(num number) {
    return ((number / 1500.0).round() * 1500).toInt();
  }

  @override
  void paint(Canvas canvas, Size size) {

    var factor = fr() ;
    double cH = mR(size.height, 0.7);
    double cW = mR(size.width, 1);
    num diff = roundToNearestThousand((p1Score - p2Score).abs());

    //region 0: background diff
    var rect = Rect.fromLTWH(0, 0,0,0);
    var begin = Alignment.bottomLeft;
    var end = Alignment.bottomRight;
    if (factor > 0.5) {
      rect = Rect.fromLTWH(0,0, size.width / 2, size.height);
    } else {
      rect = Rect.fromLTWH(size.width / 2,0, size.width / 2, size.height);
      begin = Alignment.bottomRight;
      end = Alignment.bottomLeft;
    }

    Paint paint = Paint();
    paint.shader = LinearGradient(
      begin: begin,
      end: end,
      stops: [
        0.5, 1.0
      ],
      colors: [
        Color.fromRGBO(138, 127, 50, 0.5),
        Colors.transparent,
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    //endregion

    //region part 1: score text
    final textStyle = GoogleFonts.rubik().copyWith(fontSize: 48, color: Colors.white, letterSpacing: 7);
    var textSpan = TextSpan(
      text: p1Score.toString(),
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,

    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset = Offset(mR(size.width, 0.01), mR(size.height, 0.2));
    textPainter.paint(canvas, offset);

    var textSpan2 = TextSpan(
      text: p2Score.toString(),
      style: textStyle,
    );
    final textPainter2 = TextPainter(
      text: textSpan2,
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset2 = Offset(mR(size.width, 0.77), mR(size.height, 0.2));
    textPainter2.paint(canvas, offset2);

    final textPainter4 = TextPainter(
      text: TextSpan(text: (factor > 0.5 ? "⯇ " :"") + NumberFormat.compact().format(diff) + (factor < 0.5 ? "⯈ " :""), style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    final xCenter = (size.width - textPainter4.width) / 2;
    final yCenter = (size.height - textPainter4.height) / 2;

    textPainter4.paint(canvas, Offset(xCenter, yCenter));

  /*  var textSpan3 = TextSpan(
      text: NumberFormat.compact().format(diff),
      style: textStyle,
    );
    final textPainter3 = TextPainter(
      text: textSpan3,
      textDirection: TextDirection.ltr,
        textAlign: .center
    )..layout(
    minWidth: 0,
    maxWidth: size.width,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    final offset3 = Offset(xCenter, yCenter);
    textPainter3.paint(canvas, offset3);*/

    //endregion

    //region part 2: score diff
    var p1Paint = Paint()..color = Color.fromRGBO(242, 233, 159, 1);
    var p2Paint = Paint()..color = Color.fromRGBO(182, 246, 210, 1);



    canvas.drawRect(Rect.fromLTWH(0, cH, cW, cH), p2Paint);




    canvas.save(); // save stape. clip noe!!
    double dynamicSplitX = size.width * factor;
    Rect leftClipRect = Rect.fromLTWH(0, 0, dynamicSplitX, size.height);
    canvas.clipRect(leftClipRect);
    canvas.drawRect(Rect.fromLTWH(0, cH, cW, cH), p1Paint);

   /* double dynamicSplitX = size.width * factor;
    Rect leftClipRect = Rect.fromLTWH(0, 0, dynamicSplitX, size.height);
    canvas.clipRect(leftClipRect);

    canvas.drawPath(
        Path()
          ..moveTo(0, cH)
          ..lineTo(mR(cW, 0.5), cH)
          ..lineTo(mR(cW, 0.6), mR(cH, 1.3))
          ..lineTo(cW,  mR(cH, 1.3))
          ..lineTo(cW, mR(cH, 2))
          ..lineTo(0, mR(cH, 2))
          ..lineTo(0, 0)
          ..moveTo(cW, mR(cH, 1.3))
          ..lineTo(cW + mR(cW, 0.5), mR(cH, 1.3))
          ..lineTo(cW + mR(cW, 0.6), mR(cH, 1))
          ..lineTo(cW + cW, mR(cH, 1))
          ..lineTo(cW + cW, cH + size.width)
          ..lineTo(cW, cH + size.width),

        p1Paint);*/


    canvas.restore();

    //endregion
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
