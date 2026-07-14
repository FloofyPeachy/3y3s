import 'package:a3y3s_cfg/model/plugin.dart';
import 'package:a3y3s_cfg/state.dart' show currentPreset;
import 'package:a3y3s_cfg/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:image/image.dart' as img;

class SearchAreaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchAreaPage();
}

class _SearchAreaPage extends State<SearchAreaPage> {
  bool hovered = false;

  bool dragging = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SEARCH AREA", style: fgStandardSize(48).copyWith(color: Colors.black)),
        Text(
          "Define where 3y3s will look for the numbers, and what will they mean.",
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
                size: const ResizableSize.ratio(0.5), // Takes up 30% of space initially
                child: Column(
                  mainAxisSize: .min,
                    children: [
                      Text("SETTINGS", style: fgStandardSize(36).copyWith(color: Colors.black)),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: currentPreset.searchAreas.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SearchAreaView(searchArea: currentPreset.searchAreas[index]);
                        },

                      )
                    ]
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

}

class SearchAreaView extends StatelessWidget {
  final SearchArea searchArea;

  SearchAreaView({required this.searchArea});
  @override
  Widget build(BuildContext context) {
    final imageData = currentPreset.demoImage.data!;
    final area = searchArea.area;

    final cmd = img.Command()
      ..image(imageData)
      ..copyCrop(
        x: (area.x * imageData.width).floor(),
        y: (area.y * imageData.height).floor(),
        width: area.width.round() * searchArea.characterCount,
        height: area.height.round(),
      );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                FutureBuilder(
                  future: cmd.executeThread(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState != ConnectionState.done) return SizedBox();
                    return Image(image: MemoryImage(img.encodePng(cmd.outputImage!)), fit: .scaleDown);
                  }
                ),
                Text(searchArea.meaning.toString())
              ],
            ),

          ],
        ),
      ),
    );
  }

}
























