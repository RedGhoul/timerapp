import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Timer App'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer _timer = Timer.periodic(const Duration(seconds: 1), (timer) { });
  int _currentInputSeconds = 0;
  int _currentInputMinutes = 0;
  int _currentInputHours = 0;
  int _currentSeconds = 0;
  int _currentMinutes = 0;
  int _currentHours = 0;
  bool _isTimerActive = false;
  bool _areFormFieldsEnabled = true;

  static const EdgeInsets insets = EdgeInsets.only(left:180.0, top:40.0, right:180.0);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get timerText =>
      '${_currentHours.toString().padLeft(2,'0')} : ${_currentMinutes.toString().padLeft(2,'0')} : ${_currentSeconds.toString().padLeft(2,'0')}';

  void _startTimer() {
    Duration currentDuration = Duration(hours: _currentInputHours, minutes: _currentInputMinutes, seconds: _currentInputSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (Duration(seconds: timer.tick).inSeconds == currentDuration.inSeconds) {
        setState(() {
          _timer.cancel();
          _isTimerActive = false;
          _areFormFieldsEnabled = true;
        });
        AudioPlayer().play(AssetSource('audio/natural-thunder.mp3'));
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _isTimerActive ? Column(
          children: [
            const Spacer(flex: 1,),
            Center(
              child: Text(
                timerText,
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
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Hours or Another Value';
                        }
                        return null;
                      },
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
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Minutes or Another Value';
                        }
                        return null;
                      },
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
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Seconds or Another Value';
                        }
                        return null;
                      },
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
                setState(() {
                  _isTimerActive = false;
                });
              },
            tooltip: 'Clear',
            child: const Icon(Icons.exit_to_app),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
