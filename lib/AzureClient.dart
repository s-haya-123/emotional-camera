import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class AzureRepository {
  final String url = "https://japaneast.api.cognitive.microsoft.com/face/v1.0/detect";
  Size size;
  AzureRepository(this.size);
  Future<FaceEntity> detectFaceInfo(
      File file,
      bool returnFaceId,
      bool returnFaceLandmarks,
      String returnFaceAttributes,
      String recognitionModel,
      bool returnRecognitionModel
      ) async {

    final headers = {
      "Ocp-Apim-Subscription-Key": "",
      "Content-Type":"application/octet-stream",
    };
    final parameters = "returnFaceId="+returnFaceId.toString()
        +"&returnFaceLandmarks="+returnFaceLandmarks.toString()
        +"&returnFaceAttributes="+returnFaceAttributes
        +"&recognitionModel="+recognitionModel
        +"&returnRecognitionModel="+returnRecognitionModel.toString();
    final response = await http.post(url+"?"+parameters,
        headers: headers,
        body:file.readAsBytesSync()
    );
    if (jsonDecode(response.body).length > 0) {
      return FaceEntity.fromJson(jsonDecode(response.body)[0]);
    } else {
      return null;
    }
//    return FaceEntity.fromJson(jsonDecode(response.body));
//    print(FaceEntity.fromJson(jsonDecode(response.body)[0])._faceRectangleEntity.height);
  }

}

class FaceEntity {
  String faceId;
  FaceRectangleEntity faceRectangleEntity;
  FaceAttributesEntity faceAttributesEntity;
  FaceEntity.fromJson(Map<String,dynamic> json){
    faceId = json.containsKey('faceId') ? json['faceId']:null;
    faceRectangleEntity = json.containsKey('faceRectangle') ? FaceRectangleEntity.fromJson(json['faceRectangle']):null;
    faceAttributesEntity = json.containsKey('faceAttributes') ? FaceAttributesEntity.fromJson(json['faceAttributes']):null;
  }

  Map<String,dynamic> toJson() =>
      {
        'faceId':faceId,
        'faceRectangle':faceRectangleEntity,
      };
}

class FaceRectangleEntity {
  int top;
  int left;
  int width;
  int height;
  FaceRectangleEntity(this.top,this.left,this.width,this.height);
  FaceRectangleEntity.fromJson(Map<String,dynamic> json){
    top = json.containsKey('top') ? json['top']:null;
    left = json.containsKey('left') ? json['left']:null;
    width = json.containsKey('width') ? json['width']:null;
    height = json.containsKey('height') ? json['height']:null;
  }
  Map<String,dynamic> toJson() => {
    'top': top,
    'left': left,
    'width': width,
    'height': height,
  };
   FaceRectangleEntity getDisplaySizeFaceRectangle(Size displaySize, Size pictureSize){
     double widthScale = displaySize.width / pictureSize.width;
     double heightScale = displaySize.height / pictureSize.height;
     return FaceRectangleEntity(
         (top * heightScale).toInt(),
         (left * widthScale).toInt(),
         (width * widthScale).toInt(),
         (height * heightScale).toInt()
     );
  }
  @override
  String toString() {
    return "top: ${top}, left: ${left}, width: ${width}, height: ${height}";
  }
}

class FaceAttributesEntity {
  EmotionEntity emotionEntity;
  FaceAttributesEntity.fromJson(Map<String,dynamic> json){
    emotionEntity = json.containsKey('emotion') ? EmotionEntity.fromJson(json['emotion']):null;
  }
  Map<String,dynamic> toJson() =>{
    'emotion': emotionEntity
  };
}
class EmotionEntity {
  double anger;
  double contempt;
  double disgust;
  double fear;
  double happiness;
  double neutral;
  double sadness;
  double surprise;
  EmotionEntity.fromJson(Map<String,dynamic> json){
    anger = json.containsKey('anger') ? json['anger']:null;
    contempt = json.containsKey('contempt') ? json['contempt']:null;
    disgust = json.containsKey('contempt') ? json['contempt']:null;
    fear = json.containsKey('fear') ? json['fear']:null;
    happiness = json.containsKey('happiness') ? json['happiness']:null;
    neutral = json.containsKey('neutral') ? json['neutral']:null;
    sadness = json.containsKey('sadness') ? json['sadness']:null;
    surprise = json.containsKey('surprise') ? json['surprise']:null;
  }
  Map<String,dynamic> toJson() =>{
    'anger': anger,
    'contempt': contempt,
    'disgust': disgust,
    'fear': fear,
    'happiness': happiness,
    'neutral': neutral,
    'sadness': sadness,
    'surprise': surprise
  };
}