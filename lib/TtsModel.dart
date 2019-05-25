import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState {
  playing, stopped
}
class TtsModel {
  FlutterTts flutterTts;
  dynamic languages;
  dynamic voices;
  String language;
  String voice;


  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  TtsModel() {
    flutterTts = FlutterTts();

    if (Platform.isAndroid) {
      flutterTts.ttsInitHandler(() {
        language = "ja-JP";
        voice = "ja-jp-x-htm#male_2-local";
      });
    } else if (Platform.isIOS) {
      language = "ja-JP";
    }

    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
    });

    flutterTts.setErrorHandler((msg) {
        ttsState = TtsState.stopped;
    });
  }
  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    print(languages);
  }

  Future _getVoices() async {
    voices = await flutterTts.getVoices;
    print(voices);
  }

  Future speak(String text) async {
    if (text.isNotEmpty) {
      var result = await flutterTts.speak(text);
      if (result == 1) {
        ttsState = TtsState.playing;
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      ttsState = TtsState.stopped;
    }
  }
}