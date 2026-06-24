import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/material.dart';

class SearchAreaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchAreaPage();
}

class _SearchAreaPage extends State<SearchAreaPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SEARCH AREA", style: fgStandardSize(48).copyWith(color: Colors.black)),
        Text(
          "Define where 3y3s will look for the score.",
          style: ts(context).bodyLarge,
        ),
        Divider(),
      ],
    );
  }

}
























