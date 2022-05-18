import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:share/share.dart';

class GeneratePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GeneratePageState();
}

class GeneratePageState extends State<GeneratePage> {
  String qrData =
      "https://github.com/neon97"; // already generated qr code when the page opens

  GlobalKey globalKey = new GlobalKey();
  var filepath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('QR Code Generator'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _captureAndSharePng,
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RepaintBoundary(
                  key: globalKey,
                  child: Container(
                    color: Colors.white,
                    child: QrImage(
                      //plce where the QR Image will be shown
                      data: qrData,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  "New QR Link Generator",
                  style: TextStyle(fontSize: 20.0),
                ),
                TextField(
                  controller: qrdataFeed,
                  decoration: InputDecoration(
                    hintText: "Input your link or data",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: FlatButton(
                    padding: EdgeInsets.all(15.0),
                    onPressed: () async {
                      if (qrdataFeed.text.isEmpty) {
                        //a little validation for the textfield
                        setState(() {
                          qrData = "";
                        });
                      } else {
                        setState(() {
                          qrData = qrdataFeed.text;
                        });
                      }
                    },
                    child: Text(
                      "Generate QR",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blue, width: 3.0),
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      print(pngBytes);
      String dir;
      if (Platform.isIOS) {
        dir = (await getApplicationDocumentsDirectory()).path;
      } else {
        dir = (await getExternalStorageDirectory()).path;
      }
      File file = new File('$dir/MyQR.jpg');
      await file.writeAsBytes(pngBytes);
      await file.exists().then((value) async {
        print('${file.path}');
        return;
      });
      filepath = file.path;
      print('path: ${filepath}');
      Share.shareFiles(['${filepath}'], text: 'QR Code');
    } catch (e) {
      print(e.toString());
    }
  }

  final qrdataFeed = TextEditingController();
}
