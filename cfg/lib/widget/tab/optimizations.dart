import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OptimizationsPage extends StatefulWidget {
  @override
  State<OptimizationsPage> createState() => _OptimizationsPageState();
}

class _OptimizationsPageState extends State<OptimizationsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OPTIMIZATIONS",
          style: fgStandardSize(48).copyWith(color: Colors.black),
        ),
        Text(
          "Optimize your preset, potentially making it faster and more accurate.",
          style: ts(context).bodyLarge,
        ),
        Divider(),
      ],
    );
  }
}
