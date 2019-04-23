import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras;

// 実行されるmain関数
Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {}

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

// Stateを持つWidgetオブジェクト
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  CameraController controller;
  String imagePath;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body: new Stack(
        children: <Widget>[
         Positioned.fill(
          child: _cameraPreviewWidget(),
        ),
        Positioned(
        left: 100.0,
        top: 100.0,
        right: 100.0,
        bottom: 200.0,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: _thumbnailWidget()
        ),
        ),
        ],
        ),
    );
  }
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return GestureDetector(
        onTap: onNewCameraSelected,
        child: Container(
          color: Colors.indigo,
        ),
      );
    } else {
      return GestureDetector(
        onTap: controller != null &&
            controller.value.isInitialized
            ? onTakePictureButtonPressed
            : null,
        child: new AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: new CameraPreview(controller),
        ),
      );

    }
  }
  void onNewCameraSelected() async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(cameras[0], ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {}

    if (mounted) {
      setState(() {});
    }
  }
  Widget _thumbnailWidget() {
    return  new Container(
      color: Colors.black,
        alignment: Alignment.centerRight,
        child: imagePath == null
            ? null
            : new SizedBox(
          child: new Image.file(new File(imagePath)),
        ),
    );
  }

  // カメラアイコンが押された時に呼ばれるコールバック関数
  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
      }
    });
  }
  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      return null;
    }

    return filePath;
  }
}