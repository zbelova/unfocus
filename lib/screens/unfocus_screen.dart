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

  void _startTimer() {

    //var duration = Duration(minutes: 1);
    var duration = Duration(seconds: 1);
    _timer = Timer.periodic(
      duration,
      (Timer timer) => setState(() {
        print('timer');
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
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Text(
            //   "You alarm (${widget.alarmSettings.id}) is ringing...",
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            // const Text("🔔", style: TextStyle(fontSize: 50)),
            Text('Time to Unfocus!'),
            //show timer widget
            Text(
              _formatSecondsToMinutes(_current),
              style: const TextStyle(fontSize: 30),
            ),

            ElevatedButton(onPressed: _startTimer, child: Text('Unfocus')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
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
                        ).add(Duration(minutes: _settings['unfocusDuration'].round())),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    "Set new focus",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Alarm.stopAll().then((_) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (route) => false));
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
    );
  }
}

String _formatSecondsToMinutes(int seconds) {
  var minutes = (seconds / 60).floor();
  var secondsLeft = seconds % 60;
  String secondsText = secondsLeft < 10 ? '0$secondsLeft' : secondsLeft.toString();
  return '$minutes:$secondsText';
}