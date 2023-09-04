import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/service/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:unfocus/data/user_preferences.dart';
import 'package:unfocus/screens/focus_screen.dart';
import 'package:unfocus/screens/unfocus_screen.dart';

import '../widgets/tile.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  const HomePage({super.key, this.alarmSettings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<AlarmSettings> alarms;

  static StreamSubscription? subscription;

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  Map<String, dynamic> _settings = {};
  //double? _unfocusDuration;
//   late double _focusDuration;
//   late bool _requireWalking;
//   late double _walkingDistance;
   late bool creating;
//
// // late TimeOfDay selectedTime;
//   late bool _loopAudio;
//   late bool _vibrate;
//   late bool _volumeMax;
//   late bool _showNotification;
//   late String _assetAudio;

  @override
  void initState() {
    super.initState();
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );

    _initAlarmSettings();
    // initPlatformState();
  }

  _initAlarmSettings() {
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
    creating = widget.alarmSettings == null;

    // if (creating) {
    //   loopAudio = true;
    //   vibrate = true;
    //   volumeMax = true;
    //   showNotification = true;
    //   assetAudio = 'assets/marimba.mp3';
    // } else {
    //   loopAudio = widget.alarmSettings!.loopAudio;
    //   vibrate = widget.alarmSettings!.vibrate;
    //   volumeMax = widget.alarmSettings!.volumeMax;
    //   showNotification = widget.alarmSettings!.notificationTitle != null &&
    //       widget.alarmSettings!.notificationTitle!.isNotEmpty &&
    //       widget.alarmSettings!.notificationBody != null &&
    //       widget.alarmSettings!.notificationBody!.isNotEmpty;
    //   assetAudio = widget.alarmSettings!.assetAudioPath;
    // }
  }

  // bool isToday() {
  //   final now = DateTime.now();
  //   final dateTime = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     selectedTime.hour,
  //     selectedTime.minute,
  //     0,
  //     0,
  //   );
  //
  //   return now.isBefore(dateTime);
  // }


  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initWalkingState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  void loadAlarms() {
    // AlarmStorage.unsaveAlarm(35120);
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  Future<void> navigateToSettingsScreen(AlarmSettings? alarmSettings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: SettingsScreen(),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  bool loading = false;

  void saveAlarm() {
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
      if (res) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FocusScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving alarm')));
      }
    });
    setState(() => loading = false);
  }

  AlarmSettings buildAlarmSettings() {
    final now = DateTime.now();
    final id = creating ? DateTime.now().millisecondsSinceEpoch % 100000 : widget.alarmSettings!.id;

    DateTime dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    ).add(const Duration(seconds: 10));
    if (dateTime.isBefore(DateTime.now())) {
      dateTime = dateTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      loopAudio: _settings['loopAudio'],
      vibrate: _settings['vibration'],
      volumeMax: _settings['volumeMax'],
      notificationTitle: _settings['showNotification'] ? 'Unfocus!' : null,
      notificationBody: _settings['showNotification'] ? 'Time to unfocus' : null,
      assetAudioPath: _settings['assetAudionPath'],
      stopOnNotificationOpen: false,
    );
    return alarmSettings;
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigateToSettingsScreen(null),
        label: const Icon(Icons.settings),
        elevation: 2.0,

      ),
      body: SafeArea(
        child:
            // const Text(
            //   'Steps Taken',
            //   style: TextStyle(fontSize: 30),
            // ),
            // Text(
            //   _steps,
            //   style: const TextStyle(fontSize: 60),
            // ),
            // const Divider(
            //   height: 100,
            //   thickness: 0,
            //   color: Colors.white,
            // ),
            // const Text(
            //   'Pedestrian Status',
            //   style: TextStyle(fontSize: 30),
            // ),
            // Icon(
            //   _status == 'walking'
            //       ? Icons.directions_walk
            //       : _status == 'stopped'
            //           ? Icons.accessibility_new
            //           : Icons.error,
            //   size: 100,
            // ),
            // Center(
            //   child: Text(
            //     _status,
            //     style: _status == 'walking' || _status == 'stopped' ? const TextStyle(fontSize: 30) : const TextStyle(fontSize: 20, color: Colors.red),
            //   ),
            // ),
            Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Focus: ${_settings['focusDuration'].toInt().toString()} minutes",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: CupertinoSlider(
                    value: _settings['focusDuration'],
                    min: 1,
                    max: 60,
                    onChanged: (value) {
                      setState(() {
                        _settings['focusDuration'] = value;
                      });
                      UserPreferences().setFocusDuration(value);
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Unfocus: ${_settings['unfocusDuration']!.toInt().toString()} minutes",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: CupertinoSlider(
                    value: _settings['unfocusDuration']!,
                    min: 1,
                    max: 60,
                    onChanged: (value) {
                      setState(() {
                        _settings['unfocusDuration'] = value;
                      });
                      UserPreferences().setUnfocusDuration(value);
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Require walking to unfocus",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Switch(
                        value: _settings['requireWalking'],
                        onChanged: (value) {
                          setState(() {
                            _settings['requireWalking'] = value;
                          });
                          UserPreferences().setRequireWalking(value);
                        }),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      saveAlarm();
                    },
                    child: Text("Start focus",
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
        // : Center(
        //     child: Text(
        //       "No alarms set",
        //       style: Theme.of(context).textTheme.titleMedium,
        //     ),
        //   ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(10),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       FloatingActionButton(
      //         onPressed: () {
      //           final alarmSettings = AlarmSettings(
      //             id: 42,
      //             dateTime: DateTime.now(),
      //             assetAudioPath: 'assets/marimba.mp3',
      //             volumeMax: true,
      //           );
      //           Alarm.set(alarmSettings: alarmSettings);
      //         },
      //         backgroundColor: Colors.red,
      //         heroTag: null,
      //         child: const Text("RING NOW", textAlign: TextAlign.center),
      //       ),
      //       FloatingActionButton(
      //         onPressed: () => navigateToAlarmScreen(null),
      //         child: const Icon(Icons.alarm_add_rounded, size: 33),
      //       ),
      //     ],
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}
