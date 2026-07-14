import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:a3y3s_cfg/state.dart';
import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';

class InputPage extends StatefulWidget {
  @override
  State<InputPage> createState() => _InputPage();
}

class _InputPage extends State<InputPage> {
  bool hovered = false;

  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("INPUT", style: fgStandardSize(48).copyWith(color: Colors.black)),
        Text(
          "Define what 3y3s will process.",
          style: ts(context).bodyLarge,
        ),

        Divider(),
        Expanded(
          child: ResizableContainer(
            direction: Axis.horizontal ,
            // Use Axis.vertical for top/bottom panes
            children: [
              .new(
                size: const ResizableSize.expand(),
                divider: ResizableDivider(
                  thickness: 2,
                  padding: 5,
                  length: const ResizableSize.ratio(0.25),
                  onHoverEnter: () => setState(() => hovered = true),
                  onHoverExit: () => setState(() => hovered = false),
                  onDragStart: () => setState(() => dragging = true),
                  onDragEnd: () => setState(() => dragging = false),
                  color: hovered ? Colors.blue : Colors.black,
                  cursor: SystemMouseCursors.grab,
                ),// Fills the remaining space
                child: FutureBuilder(
                  future: currentPreset.demoImage.image(), builder: (BuildContext context, AsyncSnapshot<img.Image> snapshot) {
                  if (!snapshot.hasData) return Text("Loading demo image..");
                  return Image(image: MemoryImage(img.encodePng(snapshot.data!)), fit: .scaleDown);
                },

                )/*SizedBox(
                  width: dW(context) * 0.4,
                  height: dH(context) * 0.4,
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Container(
                        color: Colors.blue,
                        child: FutureBuilder(
                          future: currentPreset.demoImage.image(), builder: (BuildContext context, AsyncSnapshot<img.Image> snapshot) {
                            if (!snapshot.hasData) return Text("Loading demo image..");
                            return Image(image: MemoryImage(img.encodePng(snapshot.data!)), fit: .scaleDown);
                        },

                        )
                      ),
                      Row(
                        children: [
                          IconButton(onPressed: () {  }, icon: Icon(Icons.flip),),
                          IconButton(onPressed: () {}, icon: Icon(Icons.rotate_left)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.rotate_right)),
                        ]
                      ),
                      Text("1920x1080 (16/9)")
                    ],
                  ),
                )*/,
              ),

                  .new(
                size: const ResizableSize.ratio(0.3), // Takes up 30% of space initially
                child: Column(
                  children: [
                    Text("SETTINGS", style: fgStandardSize(36).copyWith(color: Colors.black)),
                  ]
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}