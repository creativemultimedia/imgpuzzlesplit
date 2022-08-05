import 'dart:io';
import 'dart:typed_data';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
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
  List<Image> tempimglist=[];
  List temp=List.filled(9, false);
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
      output.add(Image.memory(Uint8List.fromList(imglib.encodeJpg(img)),fit: BoxFit.fill,));
    }

    return output;
  }
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');
    var dir_path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    File file=File(dir_path+"/img.jpg");
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }


  @override
  void initState() {
    print("Hello1");
    getImageFileFromAssets("image/download.jpg").then((value) {
      print("Hello2");
      List<int> data=value.readAsBytesSync();
      setState(() {
        list=splitImage(data);
        tempimglist.addAll(list);
        list.shuffle();
      });
      print(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("APP"),),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,mainAxisSpacing: 1,crossAxisSpacing: 1),
        itemCount:list.length,
        itemBuilder: (context, index) {
        return temp[index]?DragTarget(onAccept:(data) {
          print(data);
          setState(() {
            int t=data as int;
            Image w=list[t];
            list[t]=list[index];
            list[index]=w;
          });
          if(listEquals(tempimglist, list))
            {
              print("Success");
            }
          else
            {
              print("not");
            }
        },builder: (context, candidateData, rejectedData) {
          return Container(child: list[index]);
        },onWillAccept: (data) {
          return true;
        },
        ):
        Draggable(onDragEnd:(details) {
          temp=List.filled(9, false);
        },onDragStarted: (){
          setState(() {
            for(int i=0;i<9;i++)
              {
                if(i!=index)
                  {
                    temp[i]=true;
                  }
              }
          });
        },data:index,child: Container(child: list[index]),feedback: Container(child: list[index]),childWhenDragging: Container(),);
      },),
    );
  }
}
