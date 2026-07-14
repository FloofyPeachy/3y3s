import 'package:a3y3s_cfg/cv/vision.dart';
import 'package:a3y3s_cfg/state.dart';
import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TEST",
          style: fgStandardSize(48).copyWith(color: Colors.black),
        ),
        Text(
          "Test your preset to make sure it won't croak on the big stage.",
          style: ts(context).bodyLarge,
        ),
        Divider(),
        OutlinedButton.icon(icon: Icon(Icons.run_circle), onPressed: () async {
          var tester = VisionTester(currentPreset);
          await tester.load();
          tester.run();
        }, label: Text("Run"))
      ],
    );
  }
}