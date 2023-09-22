import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:unfocus/screens/home_screen.dart';

import '../data/user_preferences.dart';
import '../helpers/globals.dart';

class UnfocusScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const UnfocusScreen({Key? key, required this.alarmSettings}) : super(key: key);

  @override
  State<UnfocusScreen> createState() => _UnfocusScreenState();
}

class _UnfocusScreenState extends State<UnfocusScreen> {
  Map<String, dynamic> _settings = {};
  Timer? _timer;
  int _current = UserPreferences().getUnfocusDuration().floor() * 60;
  bool _unfocusRunning = false;
  bool _showTimer = false;
  bool _walkingRequired = false;
  bool _buttonDelayed = false;

  bool _isMoving = false;
  DateTime _movementStartTime = DateTime.now();
  double _movingDuration = 0;
  bool _movingComplete = false;
  bool _musicTurnedOff = false;
  bool _showUnfocusText = false;

  StreamSubscription<UserAccelerometerEvent>? _accelerometerEventsSubscription;

  void _startTimer() {

    _setFocusAlarm();
    setState(() {
      _unfocusRunning = true;
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

  void _setFocusAlarm() {
    final now = DateTime.now();
    //Alarm.stopAll();
    Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        id:222,
        notificationTitle: 'Focus!',
        notificationBody: 'Keep focused on your goals',
        assetAudioPath: 'assets/pop.mp3',
        loopAudio: false,
        dateTime: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
          now.millisecond,
        ).add(Duration(seconds: _current)),
          //TODO убрать на настоящие
        //).add(const Duration(seconds: 10)),
      ),
    );
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

        if (!_isMoving && isMovingNow) {
          // Началось движение
          setState(() {
            _isMoving = true;
            _movementStartTime = DateTime.now();
          });
        } else if (_isMoving && isMovingNow) {
          // В процессе движения
          DateTime movementEndTime = DateTime.now();
          setState(() {
            _movingDuration += _calculateMovementTime(_movementStartTime, movementEndTime);
            if (_movingDuration > _settings['walkingDuration']) {
              _movingComplete = true;
              _showTimer = true;
              _startTimer();
              _accelerometerEventsSubscription!.cancel();
            }
            _movementStartTime = movementEndTime;
          });
        } else if (_isMoving && !isMovingNow) {
          // Движение закончилось
          setState(() {
            _isMoving = false;
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
    _walkingRequired = _settings['requireWalking'];
    if (_walkingRequired) {
      _buttonDelayed = true;
      Timer(const Duration(seconds: 3), () {
        setState(() {
          _buttonDelayed = false;
        });
      });
    }
    _startSensors();
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87EDFF),
              Color(0xFF018EC7),
            ],
            stops: [
              0.1,
              1.0,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.10,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_walkingRequired && !_movingComplete) _buildWalkingHeader(context),
                      _buildGreatJob(context),
                    ],
                  ),
                ),
                if (!_showTimer && !_walkingRequired) _buildUnfocusButton(),
                _buildTimer(),
                _buildDontWantToWalk(),
                if (_showTimer) _buildPauseStop(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildDontWantToWalk() {
    return SizedBox(
      child: (!_showTimer && !_buttonDelayed && _walkingRequired)
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF85E3FF),
              ),
              onPressed: () {
               // Alarm.stopAll();
                setState(() {
                  _showTimer = true;
                  _unfocusRunning = true;
                  _movingComplete = true;
                  _showUnfocusText = true;
                });
                _startTimer();
              },
              child: const Text(
                "I don't want to walk :(",
                style: TextStyle(color: Color(0xFF0387B0), fontSize: 12),
              ),
            )
          : Container(),
    );
  }

  SizedBox _buildTimer() {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          if (_showTimer)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF83F0FF),
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
                        color: Color(0xFF484848),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!_showTimer && _walkingRequired && !_movingComplete) _buildProgress()
        ],
      ),
    );
  }

  Padding _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: LinearProgressIndicator(
        value: _movingDuration / _settings['walkingDuration'],
        minHeight: 25,
        borderRadius: BorderRadius.circular(10),
        backgroundColor: const Color(0xFFC6FAFF),
        color: const Color(0xFF35E87E),
      ),
    );
  }

  ElevatedButton _buildUnfocusButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6FAFF)),
        onPressed: () {
          Alarm.stopAll();
          setState(() {
            _showTimer = true;
            _unfocusRunning = true;
            _movingComplete = true;
            _walkingRequired = false;
            _showUnfocusText = true;
          });
          //_setFocusAlarm();
          //Alarm.stopAll();
          _startTimer();
        },
        child: const Text("Unfocus", style: TextStyle(color: Color(0xFF0387B0), fontSize: 20, height: 4)));
  }

  Column _buildGreatJob(BuildContext context) {
    return Column(
      children: [
        if (_walkingRequired && _movingComplete && !_showUnfocusText)
          Column(
            children: [
              const Text(
                'Great job!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF484848),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: const Text(
                  'Now you can relax or continue walking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF484848),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),

        if (_showUnfocusText && _movingComplete)
          const Text(
            'Time to unfocus and relax',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF484848),
            ),
          ),
        if (!_musicTurnedOff &&  _walkingRequired && _movingComplete)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6FAFF)),
              onPressed: () {
                Alarm.stop(111);
                setState(() {
                  _musicTurnedOff = true;
                });
              },
              child: const Text(
                'Turn off the music',
                style: TextStyle(color: Color(0xFF0387B0)),
              ),
            ),
          ),
      ],
    );
  }

  Column _buildWalkingHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: const Text(
            'Take your phone and walk around or dance!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF484848),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Container(
          height: 130,
          width: 100,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/walk.gif'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildPauseStop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _unfocusRunning
            ? IconButton(
                onPressed: () {
                  if (_timer != null) _timer!.cancel();
                  Alarm.stopAll();
                  setState(() {
                    _musicTurnedOff = true;
                    _unfocusRunning = false;
                  });
                },
                icon: const Icon(Icons.motion_photos_paused_outlined),
                iconSize: 40,
              )
            : IconButton(
                onPressed: () {
                  _startTimer();
                  //_setFocusAlarm();
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
      ],
    );
  }
}
