import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:unfocus/screens/focus_screen.dart';
import 'package:unfocus/screens/home_screen.dart';

import '../data/user_preferences.dart';
import '../helpers/globals.dart';
import '../helpers/notifications.dart';

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

  //String _unfocusText = 'Unfocus';
  bool _buttonDelayed = false;

  bool isMoving = false;
  DateTime movementStartTime = DateTime.now();
  double _movingDuration = 0;
  bool _movingComplete = false;
  bool musicTurnedOff = false;

  late final NotificationService notificationService;

  StreamSubscription<UserAccelerometerEvent>? _accelerometerEventsSubscription;

  void _startTimer() {
    //_addNotification();

    setState(() {
      _unfocusRunning = true;
    });

    //var duration = Duration(minutes: 1);
    var duration = const Duration(seconds: 1);
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
    notificationService.showImmediateNotification();
    final now = DateTime.now();
    Alarm.stopAll();
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
    ).then((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FocusScreen(alarmSettings: widget.alarmSettings))));
  }

  double _calculateMovementTime(DateTime oldStartTime, DateTime newStartTime) {
    Duration duration = newStartTime.difference(oldStartTime);
    duration = duration.abs();
    double inSeconds = duration.inMilliseconds / 1000;
    return inSeconds;
  }

  void _startSensors() {
    _accelerometerEventsSubscription = userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        bool isMovingNow = (event.x.abs() + event.y.abs() + event.z.abs()) > 0.5;

        if (!isMoving && isMovingNow) {
          // Началось движение
          setState(() {
            isMoving = true;
            movementStartTime = DateTime.now();
          });
        } else if (isMoving && isMovingNow) {
          // В процессе движения
          DateTime movementEndTime = DateTime.now();
          setState(() {
            _movingDuration += _calculateMovementTime(movementStartTime, movementEndTime);
            if (_movingDuration > _settings['walkingDuration']) {
              _movingComplete = true;
              _showTimer = true;
              _startTimer();
              _accelerometerEventsSubscription!.cancel();
            }
            movementStartTime = movementEndTime;
          });
        } else if (isMoving && !isMovingNow) {
          // Движение закончилось
          setState(() {
            isMoving = false;
          });
        }
      },
      onError: (e) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Sensor Not Found"),
                content: Text("It seems that your device doesn't support Accelerometer Sensor"),
              );
            });
      },
      cancelOnError: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _settings = {
      'unfocusDuration': UserPreferences().getUnfocusDuration(),
      'focusDuration': UserPreferences().getFocusDuration(),
      'requireWalking': UserPreferences().getRequireWalking(),
      'walkingDuration': UserPreferences().getWalkingDuration(),
      'loopAudio': UserPreferences().getLoopAudio(),
      'vibration': UserPreferences().getVibration(),
      'volumeMax': UserPreferences().getVolumeMax(),
      'showNotification': UserPreferences().getShowNotification(),
      'assetAudionPath': UserPreferences().getAssetAudionPath(),
    };
    _current = 15;
    _walkingRequired = _settings['requireWalking'];
    if (_walkingRequired) {
      _buttonDelayed = true;
      Timer(const Duration(seconds: 3), () {
        setState(() {
          _buttonDelayed = false;
        });
      });
    }
    else {
      // _showTimer = true;
      // _startTimer();
    }
    _startSensors();
    notificationService = NotificationService();
    notificationService.initializePlatformNotifications();
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    if (_accelerometerEventsSubscription != null) {
      _accelerometerEventsSubscription?.cancel();
    }
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
              if (_walkingRequired && !_movingComplete) const Text('Take your phone and walk around a bit or dance!'),
              if (_walkingRequired && _movingComplete)
                Column(
                  children: [
                    const Text('Great job!'),
                    const Text('Now you can relax or continue walking'),
                    if (!musicTurnedOff)
                      ElevatedButton(
                        onPressed: () {
                          Alarm.stopAll();
                          setState(() {
                            musicTurnedOff = true;
                          });
                        },
                        child: const Text('Turn off the music'),
                      ),
                  ],
                ),
              if (!_showTimer && !_buttonDelayed && _walkingRequired)
                ElevatedButton(
                    onPressed: () {
                      Alarm.stopAll();
                      setState(() {
                        _showTimer = true;
                        _unfocusRunning = true;
                      });
                      _startTimer();
                    },
                    child: Text("I don't want to walk :(")),
              if (!_showTimer && !_walkingRequired)
                ElevatedButton(
                    onPressed: () {
                      Alarm.stopAll();
                      setState(() {
                        _showTimer = true;
                        _unfocusRunning = true;
                      });
                      _startTimer();
                    },
                    child: Text("Unfocus")),
              //show timer widget
              if (_showTimer)
                Text(
                  formatSecondsToMinutes(_current),
                  style: const TextStyle(fontSize: 30),
                ),

              if (_showTimer) _buildPauseStop(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseStop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
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
    );
  }
}
