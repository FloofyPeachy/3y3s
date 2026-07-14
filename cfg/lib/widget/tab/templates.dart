import 'package:a3y3s_cfg/model/plugin.dart';
import 'package:a3y3s_cfg/state.dart';
import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:image/image.dart' as img;

class TemplatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TemplatePage();
}

class _TemplatePage extends State<TemplatePage> {
  bool hovered = false;

  bool dragging = false;

  int currentTemplate = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TEMPLATES",
          style: fgStandardSize(48).copyWith(color: Colors.black),
        ),
        Text(
          "Define what 3y3s looks for on the screen.",
          style: ts(context).bodyLarge,
        ),
        Text(
          "Select or create a template down below.",
          style: ts(context).bodyLarge,
        ),
        Divider(),
        Row(
          children: [IconButton(icon: Icon(Icons.add), onPressed: () {})],
        ),
        Expanded(
          child: ResizableContainer(
            direction: Axis.horizontal,
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
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (_, index) => TemplateView(
                    template: currentPreset.characters[index],
                    onTap: () {
                      setState(() {
                        currentTemplate = index;
                      });
                    },
                  ),
                  itemCount: currentPreset.characters.length,
                ),
              ),
                  .new(
                size: const ResizableSize.ratio(0.3), // Takes up 30% of space initially
                child: Card(
                  child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text("CHARACTER", style: fgStandardSize(36).copyWith(color: Colors.black)),
                        ),
                        Row(
                          mainAxisSize: .min,
                          children: [
                            Expanded(child: Text("Value")),
                            Expanded(
                              child: TextField(
                                cursorColor: Colors.blue,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  hintText: '4',
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                                  ),
                                ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    // 1. Only allow numerical digits
                                    FilteringTextInputFormatter.digitsOnly,
                                    // 2. Stop the user at 10 characters
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                onChanged: (value) {
                                  currentPreset.characters[currentTemplate].value = int.parse(value);
                                }
                              ),
                            ),
                          ],
                        )

                      ]
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class TemplateView extends StatelessWidget {
  final Template template;
  final Function() onTap;

  TemplateView({super.key, required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            FutureBuilder(
              future: template.data.image(),
              builder:
                  (BuildContext context, AsyncSnapshot<img.Image> snapshot) {
                    if (!snapshot.hasData) return Text("Loading demo image..");
                    return Image(
                      image: MemoryImage(img.encodePng(snapshot.data!)),
                    );
                  },
            ),
            Text(template.value.toString(), style: ts(context).titleLarge),
          ],
        ),
      ),
    );
  }
}
