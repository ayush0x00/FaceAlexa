import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool generatingImage = false;
  bool imageGenerated = false;
  String serverURL = "http://10.8.18.122:80";
  String imagePath = '';
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app

  void generateImageCall() async{
    setState(() {
      generatingImage = true;
      imageGenerated = false;
    });
    final Map<String, String> requestData = {
      'prompt': _lastWords, // Replace with your dictionary data
    };
    final response = await http.post(
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        Uri.parse('$serverURL/generate'),
        body: jsonEncode(requestData)
    );
    // print(response.body);
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    setState(() {
      generatingImage = false;
      imageGenerated = true;
    });
    if (responseBody["error"]){
      setState(() {
        hasError = true;
        imageGenerated = false;
      });
    }
    else {
    //   setState(() {
    //   imagePath = responseBody["image_path"];
    // });
      String path = responseBody["image_path"];
      Uri url = Uri.parse('$serverURL/get_image').replace(queryParameters: {'image_path': path});
      final response = await http.get(url);
      setState(() {
        imagePath = response.request!.url.toString();
        generatingImage = true;
      });
      // print(response.body);
    }

  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    setState(() {
      _lastWords = '';
    });
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void resetStates(){
    setState(() {
      generatingImage = false;
      imageGenerated = false;
      hasError = false;
      imagePath = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return generatingImage ?
    imageGenerated ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image.network(imagePath,width: 200,height: 200,),
        ),
        const SizedBox(height: 20,),
        ElevatedButton(onPressed: resetStates, child: const Text("Try again"))
      ],
    ) : 
    const Center(child: CircularProgressIndicator()) 
        :
    Scaffold(
      appBar: AppBar(
        title: const Text('Face Alexa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Microphone Icon at the Center
            GestureDetector(
              onTap: () {
                // Add your microphone icon tap logic here
                if (_speechToText.isNotListening) {
                  _startListening();
                } else {
                  _stopListening();
                }
              },
              child: Icon(
                _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                size: 100.0,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20.0), // Spacer

            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _speechEnabled
                      ? 'Tap the microphone to start listening...'
                      : 'Speech not available',
                ),
              ),
            ),
            // Recognized Words Text
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _lastWords,
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add your button click logic here
                generateImageCall();
              },
              child: const Text("Generate Image"),
            ),
          ],
        ),
      ),
    );
  }
}