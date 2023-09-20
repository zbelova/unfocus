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
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              children: [
                const Text('Focus'),
                Text(
                  formatSecondsToMinutes(_current),
                  style: const TextStyle(fontSize: 30),
                ),
                _focusRunning
                    ? ElevatedButton(
                      onPressed: () {
                        if (_timer != null) _timer!.cancel();
                        setState(() {
                          _focusRunning = false;
                          Alarm.stopAll();
                        });
                      },
                      child: Text(
                        "Pause",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                    : ElevatedButton(
                      onPressed: () {
                        _startTimer();
                        _setNewAlarm();
                      },
                      child: Text(
                        "Resume",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                ElevatedButton(
                  onPressed: () {
                    if (_timer != null) _timer!.cancel();
                    Alarm.stopAll().then((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())));
                  },
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
