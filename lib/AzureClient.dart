import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AzureRepository {
  final String url = "https://japaneast.api.cognitive.microsoft.com/face/v1.0/detect";

  detectFaceInfo(
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
    print(url+"?"+parameters);
    final response = await http.post(url+"?"+parameters,
        headers: headers,
        body:file.readAsBytesSync()
    );
    print(jsonDecode(response.body));
    print(FaceEntity.fromJson(jsonDecode(response.body)[0])._faceRectangleEntity.height);
  }

}

class FaceEntity {
  String faceId;
  FaceRectangleEntity _faceRectangleEntity;
  FaceAttributesEntity _faceAttributesEntity;
  FaceEntity.fromJson(Map<String,dynamic> json):
        faceId = json['faceId'],
        _faceRectangleEntity = FaceRectangleEntity.fromJson(json['faceRectangle']),
        _faceAttributesEntity = FaceAttributesEntity.fromJson(json['faceAttributes']);
  Map<String,dynamic> toJson() =>
      {
        'faceId':faceId,
        'faceRectangle':_faceRectangleEntity,
      };
}

class FaceRectangleEntity {
  int top;
  int left;
  int width;
  int height;
  FaceRectangleEntity.fromJson(Map<String,dynamic> json):
    top = json['top'],
    left = json['left'],
    width = json['width'],
    height = json['height'];
  Map<String,dynamic> toJson() => {
    'top': top,
    'left': left,
    'width': width,
    'height': height,
  };
}

class FaceAttributesEntity {
  EmotionEntity _emotionEntity;
  FaceAttributesEntity.fromJson(Map<String,dynamic> json):_emotionEntity = EmotionEntity.fromJson(json['emotion']);
  Map<String,dynamic> toJson() =>{
    'emotion': _emotionEntity
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
  EmotionEntity.fromJson(Map<String,dynamic> json):
    anger = json['anger'],
    contempt = json['contempt'],
    disgust = json['disgust'],
    fear = json['fear'],
    happiness = json['happiness'],
    neutral = json['neutral'],
    sadness = json['sadness'],
    surprise = json['surprise'];
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