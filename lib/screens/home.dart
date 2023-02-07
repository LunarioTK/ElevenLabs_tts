import 'dart:convert';
import 'dart:io';

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
        "https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM";
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
        audioPlayer.play(DeviceFileSource(file.path));
        isPlaying = true;
      } else {
        print("Erro: ${response.statusCode}");
      }
    } else {
      var getAudioFromHist =
          await http.get(Uri.parse(getAudioHist), headers: headers);

      final bytes = getAudioFromHist.bodyBytes;

      await file.writeAsBytes(bytes);

      if (getAudioFromHist.statusCode == 200) {
        audioPlayer.play(DeviceFileSource(file.path));
        isPlaying = true;
      } else {
        print("Erro: ${getAudioFromHist.statusCode}");
      }

      /*if (userQuest.contains(userQuest)) {
        // Checking if the audio has finished
        audioPlayer.onPlayerComplete.listen((event) {
          hasFinished = true;
        });

        if (hasFinished == false) {
          audioPlayer.resume();
          isPlaying = true;
        } else {
          audioPlayer.play(DeviceFileSource(fileAnt!.path));
          isPlaying = true;
        }
      }*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (isPlaying == false) {
              playBook(
                  "The Surprising Power of Atomic Habits. THE FATE OF British Cycling changed one day in 2003. The organization, which was the governing body for professional cycling in Great Britain, had recently hired Dave Brailsford as its new performance director.");
            } else {
              audioPlayer.pause();
              isPlaying = false;
            }
          },
          child: const Text('Api'),
        ),
      ),
    );
  }
}
