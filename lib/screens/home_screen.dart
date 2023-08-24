import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/service/storage.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:unfocus/screens/focus_screen.dart';
import 'package:unfocus/screens/ring_screen.dart';

import '../widgets/tile.dart';
import 'edit_alarm_screen.dart';

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

  double _breakDuration = 5;
  double _duration = 45;
  bool _requireWalking = true;
  double walkingDistance = 10;

  @override
  void initState() {
    super.initState();
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );

    creating = widget.alarmSettings == null;

    if (creating) {
      final dt = DateTime.now().add(const Duration(minutes: 1));
      selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      loopAudio = true;
      vibrate = true;
      volumeMax = true;
      showNotification = true;
      assetAudio = 'assets/marimba.mp3';
    } else {
      selectedTime = TimeOfDay(
        hour: widget.alarmSettings!.dateTime.hour,
        minute: widget.alarmSettings!.dateTime.minute,
      );
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volumeMax = widget.alarmSettings!.volumeMax;
      showNotification = widget.alarmSettings!.notificationTitle != null &&
          widget.alarmSettings!.notificationTitle!.isNotEmpty &&
          widget.alarmSettings!.notificationBody != null &&
          widget.alarmSettings!.notificationBody!.isNotEmpty;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
    // initPlatformState();
  }

  bool isToday() {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
      0,
      0,
    );

    return now.isBefore(dateTime);
  }

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

  void initPlatformState() {
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

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: AlarmEditScreen(alarmSettings: settings),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  bool loading = false;

  late bool creating;
  late TimeOfDay selectedTime;
  late bool loopAudio;
  late bool vibrate;
  late bool volumeMax;
  late bool showNotification;
  late String assetAudio;

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
      //selectedTime.hour,
      //selectedTime.minute,
      now.second,
      now.millisecond,
    ).add(const Duration(seconds: 10));
    if (dateTime.isBefore(DateTime.now())) {
      dateTime = dateTime.add(const Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volumeMax: volumeMax,
      notificationTitle: showNotification ? 'Alarm example' : null,
      notificationBody: showNotification ? 'Your alarm ($id) is ringing' : null,
      assetAudioPath: assetAudio,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigateToAlarmScreen(null),
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
            child:
            //alarms.isNotEmpty
               //
                // ? ListView.separated(
                //     itemCount: alarms.length,
                //     separatorBuilder: (context, index) => const Divider(height: 1),
                //     itemBuilder: (context, index) {
                //       return AlarmTile(
                //         key: Key(alarms[index].id.toString()),
                //         title: TimeOfDay(
                //           hour: alarms[index].dateTime.hour,
                //           minute: alarms[index].dateTime.minute,
                //         ).format(context),
                //         onPressed: () => navigateToAlarmScreen(alarms[index]),
                //         onDismissed: () {
                //           Alarm.stop(alarms[index].id).then((_) => loadAlarms());
                //         },
                //       );
                //     },
                //   )
                //:
            Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Focus: ${_duration.toInt().toString()} minutes",
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                        ),
                      ),
                      Slider(
                        value: _duration,
                        min: 1,
                        max: 60,
                        onChanged: (value) {
                          setState(() {
                            _duration = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Unfocus: ${_breakDuration.toInt().toString()} minutes",
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                        ),
                      ),
                      Slider(
                        value: _breakDuration,
                        min: 1,
                        max: 60,
                        onChanged: (value) {
                          setState(() {
                            _breakDuration = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(
                            "Require walking",
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Switch(
                              value: _requireWalking,
                              onChanged: (value) {
                                setState(() {
                                  _requireWalking = value;
                                });
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
