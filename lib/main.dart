import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Image> list=[];
  int horizontalPieceCount=3;
  int verticalPieceCount=3;
  List<Image> splitImage(List<int> input)
  {
    imglib.Image? image = imglib.decodeImage(input);

    int x = 0, y = 0;
    int width = (image!.width / 3).round();
    int height = (image.height / 3).round();

    // split image to parts
    List<imglib.Image> parts = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }
    // convert image from image package to Image Widget to display
    List<Image> output = [];
    for (var img in parts) {
      output.add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img))));
    }

    return output;
  }
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    getImageFileFromAssets("image/download.jpg").then((value) {
      List<int> data=value.readAsBytesSync();
      list=splitImage(data);
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // body: GridView.builder(
      //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,mainAxisSpacing: 5,crossAxisSpacing: 5),
      //   itemCount:list.length,
      //   itemBuilder: (context, index) {
      //   return GridTile(child: list[index]);
      // },),
    );
  }
}
