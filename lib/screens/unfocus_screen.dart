import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:unfocus/screens/home_screen.dart';

import '../data/user_preferences.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({Key? key, required this.alarmSettings}) : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  Map<String, dynamic> _settings = {};
  Timer? _timer;
  int _current = 0;
  bool _unfocusRunning = false;
  bool _showTimer = false;
  bool _walkingRequired = false;
  String _unfocusText = 'Unfocus';
  bool _buttonDelaid = false;

  void _startTimer() {
    setState(() {
      _unfocusRunning = true;
    });

    //var duration = Duration(minutes: 1);
    var duration = Duration(seconds: 1);
    _timer = Timer.periodic(
      duration,
      (Timer timer) => setState(() {
        if (_current <= 0) {
          timer.cancel();
          _setNewAlarm();
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
        ).add(Duration(seconds: 10)),
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  void initState() {
    super.initState();
    _settings = {
      'unfocusDuration': UserPreferences().getUnfocusDuration(),
      'focusDuration': UserPreferences().getFocusDuration(),
      'requireWalking': UserPreferences().getRequireWalking(),
      'walkingDistance': UserPreferences().getWalkingDistance(),
      'loopAudio': UserPreferences().getLoopAudio(),
      'vibration': UserPreferences().getVibration(),
      'volumeMax': UserPreferences().getVolumeMax(),
      'showNotification': UserPreferences().getShowNotification(),
      'assetAudionPath': UserPreferences().getAssetAudionPath(),
    };
    _current = 15;
    _walkingRequired = _settings['requireWalking'];
    if (_walkingRequired) {
      _buttonDelaid = true;
      Timer(Duration(seconds: 5), () {
        setState(() {
          _buttonDelaid = false;
        });
      });
      _unfocusText = "I don't want to walk :(";
    }
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Time to Unfocus!'),
              if (!_showTimer && !_buttonDelaid)
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTimer = true;
                      });
                      _startTimer();
                    },
                    child: Text(_unfocusText)),
              //show timer widget
              if (_showTimer)
                Text(
                  _formatSecondsToMinutes(_current),
                  style: const TextStyle(fontSize: 30),
                ),

              if (_showTimer)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // RawMaterialButton(
                    //   onPressed: () {
                    //     final now = DateTime.now();
                    //     Alarm.set(
                    //       alarmSettings: widget.alarmSettings.copyWith(
                    //         dateTime: DateTime(
                    //           now.year,
                    //           now.month,
                    //           now.day,
                    //           now.hour,
                    //           now.minute,
                    //           now.second,
                    //           now.millisecond,
                    //         ).add(Duration(minutes: _settings['unfocusDuration'].round())),
                    //       ),
                    //     ).then((_) => Navigator.pop(context));
                    //   },
                    //   child: Text(
                    //     "Set new focus",
                    //     style: Theme.of(context).textTheme.titleLarge,
                    //   ),
                    // ),
                    _unfocusRunning
                        ? Container(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_timer != null) _timer!.cancel();
                                setState(() {
                                  _unfocusRunning = false;
                                });
                              },
                              child: Text(
                                "Pause",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          )
                        : Container(
                            child: ElevatedButton(
                              onPressed: _startTimer,
                              child: Text(
                                "Resume",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}

String _formatSecondsToMinutes(int seconds) {
  var minutes = (seconds / 60).floor();
  var secondsLeft = seconds % 60;
  String secondsText = secondsLeft < 10 ? '0$secondsLeft' : secondsLeft.toString();
  return '$minutes:$secondsText';
}
