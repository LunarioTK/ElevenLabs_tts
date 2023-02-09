import 'dart:convert';
import 'dart:io';

import 'package:elevenlabs_tts_app/screens/audioplayer.dart';
import 'package:elevenlabs_tts_app/services/elevenlabs.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? chatResponse;
  bool isPlaying = false;
  bool hasFinished = false;

  AudioPlayer audioPlayer = AudioPlayer();
  List<String> userQuestList = [];
  Utf8Codec utf8 = const Utf8Codec();
  var decodeText;
  File? fileAnt;

  String formatText(String texto) {
    var encodeText = utf8.encode(texto);
    return decodeText = utf8.decode(encodeText);
  }

  void playBook(String userQuest) async {
    APIKey apiKey = APIKey();
    String histId = '';
    String apiUrl =
        "https://api.elevenlabs.io/v1/text-to-speech/oBblmJ2l8wOCsMUauDcR";
    String apiUrlHist = "https://api.elevenlabs.io/v1/history";

    Map<String, String> headers = {
      'accept': 'audio/mpeg',
      'xi-api-key': apiKey.getApiKey,
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> jsonData = {
      'text': userQuest,
    };

    //print(data['history'][0]['history_item_id']);

    // Get History
    var responseHist = await http.get(Uri.parse(apiUrlHist), headers: headers);
    Map<String, dynamic> data =
        json.decode(utf8.decode(responseHist.bodyBytes));

    List<dynamic> dataAll = data['history'];

    for (var element in dataAll) {
      Map<String, dynamic> every = element;
      every.forEach((key, value) {
        if (key == 'text' &&
            value.toString().toUpperCase() == userQuest.toUpperCase()) {
          histId = every['history_item_id'];
        }
      });
    }
    String getAudioHist = 'https://api.elevenlabs.io/v1/history/$histId/audio';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/audio.mp3');

    if (histId.isEmpty) {
      userQuestList.add(userQuest);

      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(jsonData));

      final bytes = response.bodyBytes;

      await file.writeAsBytes(bytes);
      fileAnt = file;

      if (response.statusCode == 200) {
        await audioPlayer.setSourceDeviceFile(file.path);
        isPlaying = true;
      } else {
        print("Erro: ${response.statusCode}");
      }
    } else {
      //print('In History');
      var getAudioFromHist =
          await http.get(Uri.parse(getAudioHist), headers: headers);

      final bytes = getAudioFromHist.bodyBytes;

      await file.writeAsBytes(bytes);

      if (getAudioFromHist.statusCode == 200) {
        await audioPlayer.setSourceDeviceFile(file.path);
        isPlaying = true;
      } else {
        print("Erro: ${getAudioFromHist.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            playBook(
                "The length of ‘average’ books seem to be changing with the evolution of writing and (self) publishing. Books are now getting shorter and shorter. For myself, I plan, for a medium length book to write about 20,000 words.");
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlayerWidget(player: audioPlayer),
              ),
            );
            /*if (isPlaying == false) {
              playBook("The Surprising Power of Atomic Habits.");
            } else {
              audioPlayer.onPlayerComplete.listen((event) {
                hasFinished = true;
                isPlaying = false;
              });
              audioPlayer.pause();
              isPlaying = false;
            }*/
          },
          child: const Text('Api'),
        ),
      ),
    );
  }
}
