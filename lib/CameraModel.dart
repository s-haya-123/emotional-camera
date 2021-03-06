import 'package:scoped_model/scoped_model.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'AzureClient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:analyze_emotion/TtsModel.dart';

enum DisplayPosition {
  TOP_RIGHT,TOP_LEFT,BOTTOM_RIGHT,BOTTOM_LEFT
}
class CameraModel extends Model {
  int coefficient = 0;
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
  CameraDescription cameras;
  TtsModel ttsModel;
  String targetState;

  CameraModel(this.cameras){
    ttsModel = TtsModel();
  }

  void startCameraPreview() async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(cameras, ResolutionPreset.high);
    controller.addListener(() {
      notifyListeners();
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {

    }
    notifyListeners();
  }

  void onTakePictureButtonPressed() async {
    String filePath = await takePicture();
    pictureFile = new File(filePath);
    FaceEntity face = await AzureRepository(displaySize).detectFaceInfo(pictureFile, true, false, "emotion", "recognition_01", false);
    setAttributesWidgetParameter(face, pictureFile);
    setCoefficient(face);
    notifyListeners();
  }
  void setCoefficient(FaceEntity face) async {
    var value = calcUnhappyCoefficient(face.faceAttributesEntity.emotionEntity);
    String speach = "おこり係数" + value.toString() + "......" + _getCoefficientString(value);
    ttsModel.speak(speach);
    coefficientValue = value;
    targetState = value > 100 ? "EXECUTION":"NOT TARGET";
  }
  String _getCoefficientString(double coefficientValue){
    if (coefficientValue <100) {
      return "執行対象ではありません。";
    } else if(coefficientValue < 300) {
      return "執行対象です。" ;
    } else {
      return "執行モード、リーサル・エリミネーター";
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
  void resetTakedPicture(){
    pictureFile = null;
    isShowResultWidget = false;
    notifyListeners();
  }
}