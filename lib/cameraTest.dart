import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'AzureClient.dart';
import 'package:image/image.dart' as pxImage;
List<CameraDescription> cameras;

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
  File pictureFile;
  double parameterWidgetLeft = 0;
  double parameterWidgetTop = 0;
  double parameterWidgetHeight = 100;
  double parameterWidgetWidth = 100;
  Size displaySize;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    displaySize = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKey,
      body: new Stack(
        children: <Widget>[
          _thumbnailWidget(),
          _parameterWidget(),
        ],
      ),
    );
  }
  Widget _thumbnailWidget() {
    return new Positioned.fill(
        child:  (controller == null || !controller.value.isInitialized) ?
            new GestureDetector(
              onTap: onNewCameraSelected,
              child: Container(
                color: Colors.indigo,
              ),
            ):
            new GestureDetector(
              onTap: controller != null &&
              controller.value.isInitialized
              ? onTakePictureButtonPressed
                  : null,
              child: new AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: new CameraPreview(controller),
              ),
            )
    );
  }
  Widget _parameterWidget() {
    return Positioned(
      left: parameterWidgetLeft,
      top: parameterWidgetTop,
      height: parameterWidgetHeight,
      width: parameterWidgetWidth,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          alignment: Alignment.centerRight,
          child: pictureFile == null
              ? new Text(
              "hello",
              style: TextStyle(
                  color:Colors.white
              )
          )
              : new SizedBox(
            child: new Image.file(pictureFile),
          ),
        ),
      ),
    );
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
    } on CameraException catch (e) {

    }

    if (mounted) {
      setState(() {});
    }
  }
  // カメラアイコンが押された時に呼ばれるコールバック関数
  void onTakePictureButtonPressed() async {
    String filePath = await takePicture();
    pictureFile = new File(filePath);
    pxImage.Image image = pxImage.decodeImage(pictureFile.readAsBytesSync());
    FaceEntity face = await AzureRepository(displaySize).detectFaceInfo(pictureFile, true, false, "emotion", "recognition_01", false);
    FaceRectangleEntity faceRectangleEntity = face.faceRectangleEntity
        .getDisplaySizeFaceRectangle(displaySize, Size(image.height.toDouble(), image.width.toDouble()));
    parameterWidgetTop = faceRectangleEntity.top.toDouble();
    parameterWidgetLeft = faceRectangleEntity.left.toDouble();
    parameterWidgetHeight = faceRectangleEntity.height.toDouble();
    parameterWidgetWidth = faceRectangleEntity.width.toDouble();
    if (mounted) {
      setState(() {});
    }
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