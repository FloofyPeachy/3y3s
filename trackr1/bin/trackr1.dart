import 'dart:io';
import 'dart:typed_data';

import 'package:trackr1/trackr1.dart' as trackr1;
import 'package:web_socket_channel/web_socket_channel.dart';
late File recFile;
late IOSink sink;
int frameCount = 0;
void main(List<String> arguments) {
  Directory current = Directory.current;
  recFile = File(current.path + "/track-" + DateTime.now().millisecondsSinceEpoch.toString() + ".csv");
  recFile.createSync();
  sink = recFile.openWrite(mode: FileMode.append);
  sink.write("Frame Count, Cab1, Cab2, Diff");

  WebSocketChannel.connect(Uri.parse("ws://localhost:9001")).stream.listen(onData).onDone(flushIt);
}

void onData(dynamic bytes) {
  Uint8List data = bytes as Uint8List;
  ByteData byteData = ByteData.sublistView(data, 0, 8);
  int result1 = byteData.getInt64(0, Endian.little);

  ByteData byteData2 = ByteData.sublistView(data, 8, 16);
  int result2 = byteData2.getInt64(0, Endian.little);

  ByteData byteData3 = ByteData.sublistView(data, 16, 20);

  int result3 = byteData3.getInt32(0, Endian.little);
  sink.write(frameCount);
  sink.write(",");
  sink.write(result1);
  sink.write(",");
  sink.write(result2);
  sink.write(",");
  sink.write(result3);
  sink.write("\n");
  frameCount++;
}


void flushIt() {
  sink.flush();
  sink.close();
  print("All done!");
}
