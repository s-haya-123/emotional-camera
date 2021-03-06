import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'AzureClient.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

List<CameraDescription> cameras;

enum DisplayPosition {
  TOP_RIGHT,TOP_LEFT,BOTTOM_RIGHT,BOTTOM_LEFT
}
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
  double rectangleWidgetLeft = 0;
  double rectangleWidgetTop = 0;
  double rectangleWidgetHeight = 100;
  double rectangleWidgetWidth = 100;

  double coefficientWidgetLeft = 0;
  double coefficientWidgetTop = 0;
  double coefficientValue = 0;
  final double coefficientWidgetHeight = 100;
  final double coefficientWidgetWidth = 100;
  Size displaySize;
  bool isShowResultWidget = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }
  @override
  Widget build(BuildContext context) {
    displaySize = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKey,
      body: new Stack(
        children: <Widget>[
          _thumbnailWidget(),
          _rectangleWidget(),
          _coefficientWidget(),
          _overayImageWidget(),
          _cameraWidget(),
        ],
      ),
    );
  }

  Widget _overayImageWidget() {
    return Positioned.fill(
        child: Image.asset(
          'images/psychopass.png',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        )
    );
  }

  Widget _coefficientWidget() {
    return isShowResultWidget ? Stack(
      children: <Widget>[
        Positioned(
          left: coefficientWidgetLeft,
          top: coefficientWidgetTop,
          height: coefficientWidgetHeight,
          width: coefficientWidgetWidth,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.5),
                  width: 7.0
              ),
            ),
          )
        ),
        Positioned(
          left: coefficientWidgetLeft + coefficientWidgetWidth /2,
          top: coefficientWidgetTop + coefficientWidgetHeight / 3,
          child: Text(
            coefficientValue.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 30,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            textAlign: TextAlign.left,
          )
        ),
        Positioned(
          left: coefficientWidgetLeft + coefficientWidgetWidth /2,
          top: coefficientWidgetTop + coefficientWidgetHeight / 3 - 20,
          width: 90,
          height: 12,
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            child: Text(
              "COEFFICIENT",
              style: TextStyle( color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        Positioned(
          left: coefficientWidgetLeft + coefficientWidgetWidth /2,
          top: coefficientWidgetTop + coefficientWidgetHeight / 3 + 35,
          width: 90,
          height: 12,
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.5),
            child: Text(
              "TARGET",
              style: TextStyle( color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        Positioned(
            left: coefficientWidgetLeft + coefficientWidgetWidth /2,
            top: coefficientWidgetTop + coefficientWidgetHeight / 3 + 47,
            child: Text(
              coefficientValue > 100 ? "EXECUTION":"NOT TARGET",
              style: TextStyle(
                fontSize: 15,
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
              textAlign: TextAlign.left,
            )
        ),
      ],
    )
        : Container();
  }
  Widget _cameraWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child:
         RaisedButton(
          color: Colors.green,
          onPressed: () {
            if(isStartCamera() && pictureFile == null) {
              onTakePictureButtonPressed();
            } else if(isStartCamera() && pictureFile  != null) {
              setState(() {
                pictureFile = null;
                isShowResultWidget = false;
              });
            } else {
              startCameraPreview();
            }
          },
          child: Text(
            isStartCamera() && pictureFile == null ? "ANALYZE": "START",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
         ),
    );
  }
  Widget _thumbnailWidget() {
    return new Positioned.fill(
        child:  !isStartCamera()
            ? Container(
                color: Colors.blue,
              )
            : _takedPictureWidget(),
    );
  }
  Widget _takedPictureWidget() {
    return pictureFile == null
        ? new AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: new CameraPreview(controller),
          )
        : Image.file(
          pictureFile,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        );
  }
  bool isStartCamera(){
    return controller != null && controller.value.isInitialized;
  }
  Widget _rectangleWidget() {
    return Positioned(
      left: rectangleWidgetLeft,
      top: rectangleWidgetTop,
      height: rectangleWidgetHeight,
      width: rectangleWidgetWidth,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          child: isShowResultWidget
              ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.red,
                      width: 7.0
                  ),
                ),
              )
              : Container(),
        ),
      ),
    );
  }
  void startCameraPreview() async {
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

    FlutterTts flutterTts = new FlutterTts();
    List<dynamic> languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage("en-us");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.isLanguageAvailable("en-us");
    var result = await flutterTts.speak("Hello World");
    print(result);
    if (mounted) {
      setState(() {});
    }
  }
  // カメラアイコンが押された時に呼ばれるコールバック関数
  void onTakePictureButtonPressed() async {
    String filePath = await takePicture();
    pictureFile = new File(filePath);
    FaceEntity face = await AzureRepository(displaySize).detectFaceInfo(pictureFile, true, false, "emotion", "recognition_01", false);
    setAttributesWidgetParameter(face, pictureFile);
    if (mounted) {
      setState(() {});
    }
  }

  void setAttributesWidgetParameter(FaceEntity face, File pictureFile) async {
    ImageProperties image = await FlutterNativeImage.getImageProperties(pictureFile.path);
    if (face != null && face.faceRectangleEntity != null){
      Size imageSize = getImageSize(displaySize,image);
      FaceRectangleEntity faceRectangleEntity = face.faceRectangleEntity
          .getDisplaySizeFaceRectangle(displaySize, imageSize);
      rectangleWidgetTop = faceRectangleEntity.top.toDouble();
      rectangleWidgetLeft = faceRectangleEntity.left.toDouble();
      rectangleWidgetHeight = faceRectangleEntity.height.toDouble();
      rectangleWidgetWidth = faceRectangleEntity.width.toDouble();
      isShowResultWidget = true;

      coefficientValue = calcUnhappyCoefficient(face.faceAttributesEntity.emotionEntity);

      switch (getDisplayPosition(displaySize, rectangleWidgetLeft, rectangleWidgetTop)) {
        case DisplayPosition.BOTTOM_RIGHT: {
          coefficientWidgetTop = rectangleWidgetTop - coefficientWidgetHeight;
          coefficientWidgetLeft = rectangleWidgetLeft - coefficientWidgetWidth;
          break;
        }
        case DisplayPosition.BOTTOM_LEFT: {
          coefficientWidgetTop = rectangleWidgetTop - coefficientWidgetHeight;
          coefficientWidgetLeft = rectangleWidgetLeft + rectangleWidgetWidth;
          break;
        }
        case DisplayPosition.TOP_RIGHT: {
          coefficientWidgetTop = rectangleWidgetTop + rectangleWidgetHeight;
          coefficientWidgetLeft = rectangleWidgetLeft - coefficientWidgetWidth;
          break;
        }
        case DisplayPosition.TOP_LEFT: {
          coefficientWidgetTop = rectangleWidgetTop + rectangleWidgetHeight;
          coefficientWidgetLeft = rectangleWidgetLeft + rectangleWidgetWidth;
          break;
        }
        default: {
          break;
        }
      }
    }
  }
  Size getImageSize(Size displaySize, ImageProperties image){
    if (
        (displaySize.width > displaySize.height && image.width > image.height)
        || (displaySize.width < displaySize.height && image.width < image.height)
    ) {
      return Size(image.width.toDouble(),image.height.toDouble());
    } else {
      return Size(image.height.toDouble(),image.width.toDouble());
    }
  }

  double calcUnhappyCoefficient(EmotionEntity emotionEntity){
    return emotionEntity.anger * 300 + emotionEntity.disgust * 100 + emotionEntity.sadness * 300 + emotionEntity.contempt * 100;
  }
  DisplayPosition getDisplayPosition(Size displaySize, double faceLeft, double faceTop){
    if(faceLeft < displaySize.width /2 && faceTop < displaySize.height / 2){
      return DisplayPosition.TOP_LEFT;
    } else if(faceLeft >= displaySize.width /2 && faceTop < displaySize.height / 2) {
      return DisplayPosition.TOP_RIGHT;
    }
    else if(faceLeft < displaySize.width /2 && faceTop >= displaySize.height / 2) {
      return DisplayPosition.BOTTOM_LEFT;
    } else {
      return DisplayPosition.BOTTOM_RIGHT;
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