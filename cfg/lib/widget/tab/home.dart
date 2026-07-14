import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("PRESET", style: fgStandardSize(48).copyWith(color: Colors.black)),
        Text(
          "This is the 3y3s preset configuration tool.",
          style: ts(context).bodyLarge,
        ),
        Divider(),
      ],
    );
  }

}

