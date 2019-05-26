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
  final String language = "ja-JP";
  String voice = "ja-jp-x-htm#male_2-local";
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  TtsModel() {
    flutterTts = FlutterTts();
    flutterTts.setPitch(0.8);
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