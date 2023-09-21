import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unfocus/data/user_preferences.dart';
import 'package:unfocus/screens/focus_screen.dart';
import 'package:unfocus/screens/unfocus_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  const HomePage({super.key, this.alarmSettings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<AlarmSettings> alarms;

  static StreamSubscription? _alarmSubscription;

  Map<String, dynamic> _settings = {};
  bool loading = false;

  late bool creating;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
    _alarmSubscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
    _initAlarmSettings();
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }

  _initAlarmSettings() {
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
    creating = widget.alarmSettings == null;
  }

  void _loadAlarms() {
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
    _loadAlarms();
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

    if (res != null && res == true) _loadAlarms();
  }

  void saveAlarm() {
    setState(() => loading = true);
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
    final alarmSettings = buildAlarmSettings();
    Alarm.set(alarmSettings: alarmSettings).then((res) {
      if (res) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FocusScreen(
                      alarmSettings: alarmSettings,
                    )));
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
    ).add(const Duration(seconds: 8));
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
       floatingActionButton: IconButton(
        icon: const Icon(Icons.settings, size: 30,),
        onPressed: () => navigateToSettingsScreen(null),),
       //FloatingActionButton.extended(
      //   onPressed: () => navigateToSettingsScreen(null),
      //   label: const Icon(Icons.settings),
      //   elevation: 2.0,
      // ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/5.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Focus: ${_settings['focusDuration'].toInt().toString()} minutes",
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headlineMedium!.fontSize,
                      color: Colors.white,
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
                      color: Colors.white,
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
                          color: Colors.white,
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
        ),
      ),
    );
  }
}

