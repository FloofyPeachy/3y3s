import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pacemkr/diff_painter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int frameCount = 0;
  int p1Score = 0;
  int p2Score = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        stream: WebSocketChannel.connect(Uri.parse("ws://localhost:9001")).stream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if (snapshot.hasData && frameCount >= 3) {
            Uint8List data = snapshot.data as Uint8List;

            ByteData byteData = ByteData.sublistView(data, 0, 8);
            p1Score = byteData.getInt64(0, Endian.little);

            ByteData byteData2 = ByteData.sublistView(data, 8, 16);
           p2Score = byteData2.getInt64(0, Endian.little);

            ByteData byteData3 = ByteData.sublistView(data, 16, 20);

            int result3 = byteData3.getInt32(0, Endian.little);
            frameCount = 0;
          }
          frameCount++;

          return Column(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: DiffPainter(p1Score: p1Score, p2Score: p2Score),
                  child: SizedBox(width: double.infinity, height: double.infinity),
                ),
              ),
            /*  Expanded(
                flex: 2,
                child: Container(color: Colors.grey),
              ),
              Expanded(
                flex: 2,
                child: Container(color: Colors.grey),
              )*/
            ],
          );
          /*return Column(
            children: [
              Text(data.join(",")),
              Text(result1.toString()),
              Text(result2.toString()),
              Text(result3.abs().toString()),
              Row(
                children: [
                  SizedBox(width: 900, height: 20, child: LinearProgressIndicator(value: result1 / 10000000)),
                  Text(result1.toString()),
                ],
              ),
              SizedBox(height: 40),
              Text(result3.abs().toString()),
              SizedBox(height: 40),
              Row(
                children: [
                  SizedBox(width: 900, height: 20, child: LinearProgressIndicator(value: result2 / 10000000)),
                  Text(result2.toString()),
                ],
              ),
            ],
          );*/
        },),

    );
  }
}
