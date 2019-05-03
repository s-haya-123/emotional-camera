import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'AzureClient.dart';
import 'package:image/image.dart' as pxImage;
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
  File file;
  double left = 219;
  double top = 179;
  double height = 400.0;
  double width = 200.0;
  Size size = null;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKey,
      body: new Stack(
        children: <Widget>[
         Positioned.fill(
            child: _cameraPreviewWidget(),
          ),
          Positioned(
            left: left,
            top: top,
            height: height,
            width: width,
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
    } on CameraException catch (e) {

    }

    if (mounted) {
      setState(() {});
    }
  }
  Widget _thumbnailWidget() {
    return  new Container(
      color: Colors.black,
      alignment: Alignment.centerRight,
      child: file == null
          ? new Text(
              "hello",
              style: TextStyle(
                  color:Colors.white
              )
            )
          : new SizedBox(
            child: new Image.file(file),
      ),
    );
  }

  // カメラアイコンが押された時に呼ばれるコールバック関数
  void onTakePictureButtonPressed() async {
    String filePath = await takePicture();
    file = new File(filePath);
    pxImage.Image image = pxImage.decodeImage(file.readAsBytesSync());
    FaceEntity face = await AzureRepository(size).detectFaceInfo(file, true, false, "emotion", "recognition_01", false);
    FaceRectangleEntity faceRectangleEntity = face.faceRectangleEntity
        .getDisplaySizeFaceRectangle(size, Size(image.height.toDouble(), image.width.toDouble()));
    top = faceRectangleEntity.top.toDouble();
    left = faceRectangleEntity.left.toDouble();
    height = faceRectangleEntity.height.toDouble();
    width = faceRectangleEntity.width.toDouble();
//    print("${size.width}, ${size.height}");
//    print("${image.width}, ${image.height}");
//    print(face.faceRectangleEntity.toString());
//    print(faceRectangleEntity.toString());
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