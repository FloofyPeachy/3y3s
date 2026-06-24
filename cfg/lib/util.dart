import 'package:flutter/material.dart';

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