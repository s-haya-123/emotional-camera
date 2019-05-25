import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:analyze_emotion/CameraModel.dart';
import 'package:scoped_model/scoped_model.dart';

List<CameraDescription> cameras;

// 実行されるmain関数
Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {}
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: ScopedModel<CameraModel>(model: CameraModel(cameras[0]), child: _MyHomePageState())
    );
  }
}

class _MyHomePageState extends StatelessWidget {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size displaySize = MediaQuery.of(context).size;
    return ScopedModelDescendant<CameraModel>(
      builder: (context, child, model) {
        model.displaySize = displaySize;
        return new Scaffold(
        key: _scaffoldKey,
        body: new Stack(
          children: <Widget>[
            _thumbnailWidget(model),
            _rectangleWidget(model),
            _coefficientWidget(model),
            _overayImageWidget(),
            _cameraWidget(model),
          ],
        ),
      );
      }
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

  Widget _coefficientWidget(CameraModel model) {
    return model.isShowResultWidget ? Stack(
      children: <Widget>[
        Positioned(
            left: model.coefficientWidgetLeft,
            top: model.coefficientWidgetTop,
            height: model.coefficientWidgetHeight,
            width: model.coefficientWidgetWidth,
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
            left: model.coefficientWidgetLeft + model.coefficientWidgetWidth /2,
            top: model.coefficientWidgetTop + model.coefficientWidgetHeight / 3,
            child: Text(
              model.coefficientValue.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 30,
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
              textAlign: TextAlign.left,
            )
        ),
        Positioned(
          left: model.coefficientWidgetLeft + model.coefficientWidgetWidth /2,
          top: model.coefficientWidgetTop + model.coefficientWidgetHeight / 3 - 20,
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
          left: model.coefficientWidgetLeft + model.coefficientWidgetWidth /2,
          top: model.coefficientWidgetTop + model.coefficientWidgetHeight / 3 + 35,
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
            left: model.coefficientWidgetLeft + model.coefficientWidgetWidth /2,
            top: model.coefficientWidgetTop + model.coefficientWidgetHeight / 3 + 47,
            child: Text(
              model.coefficientValue > 100 ? "EXECUTION":"NOT TARGET",
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
  Widget _cameraWidget(CameraModel model) {
    return Align(
      alignment: Alignment.bottomCenter,
      child:
      RaisedButton(
        color: Colors.green,
        onPressed: () {
          if(isStartCamera(model) && model.pictureFile == null) {
            model.onTakePictureButtonPressed();
          } else if(isStartCamera(model) && model.pictureFile  != null) {
            model.resetTakedPicture();
          } else {
            model.startCameraPreview();
          }
        },
        child: Text(
          isStartCamera(model) && model.pictureFile == null ? "ANALYZE": "START",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  Widget _thumbnailWidget(CameraModel model) {
    return new Positioned.fill(
      child:  !isStartCamera(model)
          ? Container(
        color: Colors.blue,
      )
          : _takedPictureWidget(model),
    );
  }
  Widget _takedPictureWidget(CameraModel model) {
    return ScopedModelDescendant<CameraModel>(
      builder: (context, child, model) {
        return model.pictureFile == null
            ? new AspectRatio(
          aspectRatio: model.controller.value.aspectRatio,
          child: new CameraPreview(model.controller),
        )
            : Image.file(
          model.pictureFile,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        );
      },
    );
  }
  bool isStartCamera(CameraModel model){
    return model.controller != null && model.controller.value.isInitialized;
  }
  Widget _rectangleWidget(CameraModel model) {
    return Positioned(
      left: model.rectangleWidgetLeft,
      top: model.rectangleWidgetTop,
      height: model.rectangleWidgetHeight,
      width: model.rectangleWidgetWidth,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          child: model.isShowResultWidget
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
}