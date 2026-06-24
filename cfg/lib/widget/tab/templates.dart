import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/material.dart';

class TemplatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TemplatePage();
}

class _TemplatePage extends State<TemplatePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TEMPLATES", style: fgStandardSize(48).copyWith(color: Colors.black)),
        Text(
          "Define what 3y3s looks for on the screen.",
          style: ts(context).bodyLarge,
        ),
        Text(
          "Select or create a template down below.",
          style: ts(context).bodyLarge,
        ),
        Divider(),
      ],
    );
  }

}

