import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:unfocus/data/user_preferences.dart';
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
  int _current = UserPreferences().getFocusDuration().floor() * 60;

  void _startTimer() {
    Alarm.stopAll();
    _setUnfocusAlarm();
    setState(() {
      _focusRunning = true;
    });

    var duration = const Duration(seconds: 1);
    _timer = Timer.periodic(
      duration,
      (Timer timer) => setState(() {
        if (_current <= 0) {
          timer.cancel();
        } else {
          _current--;
        }
      }),
    );
  }

  void _setUnfocusAlarm() {
    final now = DateTime.now();
    Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        id: 111,
        notificationTitle: UserPreferences().getShowNotification() ? 'Unfocus!' : null,
        notificationBody: UserPreferences().getShowNotification() ?'Take a break' : null,
        assetAudioPath: UserPreferences().getAssetAudionPath(),
        dateTime: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
          now.millisecond,
        ).add(Duration(seconds: _current)),
          //TODO для тестов
        //).add(Duration(seconds: 10)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

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
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.10,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.33,
                  child: const Text(
                    'Focus',
                    style: TextStyle(
                      fontSize: 40,
                      color: Color(0xFF565656),
                    ),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: Center(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFECD1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SizedBox(
                          width: 160,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                formatSecondsToMinutes(_current),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Color(0xFF565656),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildPauseStop(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildPauseStop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _focusRunning
            ? IconButton(
                onPressed: () {
                  if (_timer != null) _timer!.cancel();
                 // Alarm.stopAll();
                  Alarm.stop(222);
                  Alarm.stop(111);
                  setState(() {
                    _focusRunning = false;
                  });
                },
                icon: const Icon(Icons.motion_photos_paused_outlined),
                iconSize: 40,
              )
            : IconButton(
                onPressed: () {
                  _startTimer();
                },
                icon: const Icon(Icons.play_arrow_rounded),
                iconSize: 40,
              ),
        IconButton(
          onPressed: () {
            if (_timer != null) _timer!.cancel();
            Alarm.stop(222);
            Alarm.stop(111);
            Alarm.stopAll().then((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())));
          },
          icon: const Icon(Icons.stop_rounded),
          iconSize: 40,
        ),
      ],
    );
  }
}
