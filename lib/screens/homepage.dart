import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:unfocus/screens/ring.dart';

import '../widgets/tile.dart';
import 'edit_alarm.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

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
    // initPlatformState();
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
            child: alarms.isNotEmpty
                ? Text('Hello')
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Focus: ${_duration.toInt().toString()} minutes",
                        style: const TextStyle(
                          fontSize: 30,
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
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Unfocus: ${_breakDuration.toInt().toString()} minutes",
                        style: const TextStyle(
                          fontSize: 30,
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
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Require walking",
                            style: const TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          SizedBox(
                            width: 20,),
                          Switch(
                              value: _requireWalking,
                              onChanged: (value) {
                                setState(() {
                                  _requireWalking = value;
                                });
                              }),
                        ],
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
