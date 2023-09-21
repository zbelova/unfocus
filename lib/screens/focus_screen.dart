import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import '../helpers/globals.dart';
import 'home_screen.dart';

class FocusScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const FocusScreen({super.key, required this.alarmSettings});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;
  bool _focusRunning = false;
  int _current = 0;

  void _startTimer() {
    setState(() {
      _focusRunning = true;
    });

    var duration = const Duration(seconds: 1);
    _timer = Timer.periodic(
      duration,
      (Timer timer) => setState(() {
        if (_current <= 0) {
          timer.cancel();
          //_setNewAlarm();
        } else {
          _current--;
        }
      }),
    );
  }

  void _setNewAlarm() {
    final now = DateTime.now();
    Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        dateTime: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
          now.millisecond,
          //).add(Duration(minutes: _settings['focusDuration'].round())),
        ).add(Duration(seconds: _current)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _current = 8;
    _startTimer();
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/6.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Focus',
                  style: TextStyle(
                    fontSize: 40,
                    color: Color(0xFF565656),
                  ),
                ),
                Text(
                  formatSecondsToMinutes(_current),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Color(0xFF565656),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _focusRunning
                        ? IconButton(
                            onPressed: () {
                              if (_timer != null) _timer!.cancel();
                              setState(() {
                                _focusRunning = false;
                                Alarm.stopAll();
                              });
                            },
                            icon: const Icon(Icons.motion_photos_paused_outlined),
                            iconSize: 40,
                          )
                        : IconButton(
                            onPressed: () {
                              _startTimer();
                              _setNewAlarm();
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            iconSize: 40,
                          ),

                    IconButton(
                      onPressed: () {
                        if (_timer != null) _timer!.cancel();
                        Alarm.stopAll().then((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())));
                      },
                      icon: const Icon(Icons.stop_rounded),
                      iconSize: 40,
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     if (_timer != null) _timer!.cancel();
                    //     Alarm.stopAll().then((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())));
                    //   },
                    //   child: Text(
                    //     "Stop",
                    //     style: Theme.of(context).textTheme.titleLarge,
                    //   ),
                    // ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
