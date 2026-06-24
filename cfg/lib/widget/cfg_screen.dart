import 'package:a3y3s_cfg/widget/tab/input.dart';
import 'package:a3y3s_cfg/widget/tab/searcharea.dart';
import 'package:a3y3s_cfg/widget/tab/templates.dart';
import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget {
  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  int _index = 0;
  Map<NavigationRailDestination, Widget> dests = {
    NavigationRailDestination(icon: Icon(Icons.home), label: Text("Home")):
        Text("Home"),
    NavigationRailDestination(icon: Icon(Icons.input), label: Text("Input")) : InputPage(),
    NavigationRailDestination(icon: Icon(Icons.photo), label: Text("Templates")) : TemplatePage(),
    NavigationRailDestination(icon: Icon(Icons.crop), label: Text("Search Area")) : SearchAreaPage(),
    NavigationRailDestination(icon: Icon(Icons.output), label: Text("Output")) : SearchAreaPage(),
    NavigationRailDestination(icon: Icon(Icons.science), label: Text("Test")) : Text("Settings")
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              destinations: dests.keys.toList(),
              onDestinationSelected: (dest) {
                setState(() {
                  _index = dest;
                });
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // This is the main content.
            Expanded(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: dests.values.toList()[_index],
            )),
          ],
        ),
      ),
    );
  }
}
