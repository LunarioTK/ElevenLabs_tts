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

  void getResponse(String userQuest) async {
    APIKey apiKey = APIKey();
    String apiUrl =
        "https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM";

    Map<String, String> headers = {
      'accept': 'audio/mpeg',
      'xi-api-key': apiKey.getApiKey,
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> jsonData = {
      'text': userQuest,
    };

    //response = requests.post(apiUrl, headers = headers, json = jsonData);

    var response = await http.post(Uri.parse(apiUrl),
        headers: headers, body: json.encode(jsonData));
    AudioPlayer audioPlayer = AudioPlayer();
    final bytes = response.bodyBytes;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/audio.wav');
    //print(dir.path);
    await file.writeAsBytes(bytes);

    if (response.statusCode == 200) {
      //var data = json.decode(utf8.decode(response.bodyBytes));
      //await audioPlayer.setSourceDeviceFile(file.path);
      audioPlayer.play(DeviceFileSource(file.path));
      //audioPlayer.play(audioPlayer.setSourceDeviceFile(file.path))
    } else {
      setState(() {
        //chatResponse = ("Erro: ${response.statusCode}");
        print("Erro: ${response.statusCode}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            getResponse(
                'The Surprising Power of Atomic Habits. THE FATE OF British Cycling changed one day in 2003. The organization, which was the governing body for professional cycling in Great Britain, had recently hired Dave Brailsford as its new performance director.');
          },
          child: const Text('Api'),
        ),
      ),
    );
  }
}
