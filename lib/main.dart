import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Timer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Timer App'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentInputSeconds = 0;
  int _currentInputMinutes = 0;
  int _currentInputHours = 0;
  int _currentSeconds = 0;
  int _currentMinutes = 0;
  int _currentHours = 0;
  bool _isTimerActive = false;
  bool _areFormFieldsEnabled = true;

  late AudioPlayer _audioPlayer;
  late Timer _timer;
  static const EdgeInsets insets = EdgeInsets.only(left:180.0, top:40.0, right:180.0);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get timerChangeText =>
      '${_currentHours.toString().padLeft(2,'0')} : ${_currentMinutes.toString().padLeft(2,'0')} : ${_currentSeconds.toString().padLeft(2,'0')}';


  void _setWindowSize() async {
    var size = await DesktopWindow.getWindowSize();
    await DesktopWindow.setMinWindowSize(Size(size.width * 0.9,size.height));
    await DesktopWindow.setMaxWindowSize(Size(size.width * 0.9,size.height));
  }

  void _startTimer() {
    Duration currentDuration = Duration(hours: _currentInputHours, minutes: _currentInputMinutes, seconds: _currentInputSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (Duration(seconds: timer.tick).inSeconds == currentDuration.inSeconds) {
        setState(() {
          _timer.cancel();
          _isTimerActive = false;
          _areFormFieldsEnabled = true;
          _audioPlayer.play(AssetSource('audio/natural-thunder.mp3'));
        });
      } else {
        setState(() {
          _isTimerActive = true;
          Duration newDuration = Duration(seconds: timer.tick);
          _currentSeconds = newDuration.inSeconds % 60;
          _currentMinutes = newDuration.inSeconds ~/ 60;
          _currentHours = newDuration.inSeconds / 60 ~/ 60;
        });
      }},
    );
  }

  @override
  void initState() {
    super.initState();
    _setWindowSize();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _isTimerActive ? Column(
          children: [
            const Spacer(flex: 1,),
            const Center(
              child: Text(
                'Counting Up To:',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            Center(
              child: Text(
                '${_currentInputHours.toString().padLeft(2,'0')} : ${_currentInputMinutes.toString().padLeft(2,'0')} : ${_currentInputSeconds.toString().padLeft(2,'0')}',
                style: const TextStyle(fontSize: 160, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            const Spacer(flex: 1,),
            Center(
              child: Text(
                timerChangeText,
                style: const TextStyle(fontSize: 160, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            const Spacer(flex: 2,),
          ],
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 1,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: insets,
                    child: TextFormField(
                      enabled: _areFormFieldsEnabled,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Hours',
                      ),
                      onChanged: (String? value) {
                        if(value != null && value.isNotEmpty){
                          _currentInputHours = int.parse(value);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: insets,
                    child: TextFormField(
                      enabled: _areFormFieldsEnabled,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Minutes',
                      ),
                      onChanged: (String? value) {
                        if(value != null && value.isNotEmpty){
                          _currentInputMinutes = int.parse(value);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: insets,
                    child: TextFormField(
                      enabled: _areFormFieldsEnabled,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Seconds',
                      ),
                      onChanged: (String? value) {
                        if(value != null && value.isNotEmpty){
                          _currentInputSeconds = int.parse(value);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 100)
                      ),
                      onPressed: () {
                        if (_currentInputSeconds > 0
                            || _currentInputHours > 0
                            || _currentInputMinutes > 0) {
                          _startTimer();
                          _formKey.currentState!.validate();
                          setState(() {
                            _areFormFieldsEnabled = false;
                          });
                        }
                      },
                      child: const Text('Start', style: TextStyle(fontSize: 20),),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 4,),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 120,
        width: 120,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: (){
                _timer.cancel();
                _audioPlayer.stop();
                setState(() {
                  _areFormFieldsEnabled = true;
                  _isTimerActive = false;
                });
              },
            tooltip: 'Clear',
            child: const Icon(Icons.exit_to_app),
          ),
        ),
      ),
    );
  }
}
