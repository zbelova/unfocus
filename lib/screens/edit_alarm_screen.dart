import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import '../data/user_preferences.dart';

class AlarmEditScreen extends StatefulWidget {
  final AlarmSettings? alarmSettings;
  final Map<String, dynamic> settings;

  const AlarmEditScreen({Key? key, this.alarmSettings, required this.settings})
      : super(key: key);

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  bool loading = false;
  Map<String, dynamic> _newSettings = {};

  // late bool creating;
  // //late TimeOfDay selectedTime;
  // late bool loopAudio;
  // late bool vibrate;
  // late bool volumeMax;
  // late bool showNotification;
  // late String assetAudio;

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

  @override
  void initState() {
    super.initState();
    _newSettings = widget.settings;
    // creating = widget.alarmSettings == null;
    //
    // if (creating) {
    //   // final dt = DateTime.now().add(const Duration(minutes: 1));
    //   // selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    //   loopAudio = true;
    //   vibrate = true;
    //   volumeMax = true;
    //   showNotification = true;
    //   assetAudio = 'assets/marimba.mp3';
    // } else {
    //   selectedTime = TimeOfDay(
    //     hour: widget.alarmSettings!.dateTime.hour,
    //     minute: widget.alarmSettings!.dateTime.minute,
    //   );
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

  // Future<void> pickTime() async {
  //   final res = await showTimePicker(
  //     initialTime: selectedTime,
  //     context: context,
  //   );
  //   if (res != null) setState(() => selectedTime = res);
  // }

  // AlarmSettings buildAlarmSettings() {
  //   final now = DateTime.now();
  //   // final id = creating
  //   //     ? DateTime.now().millisecondsSinceEpoch % 100000
  //   //     : widget.alarmSettings!.id;
  //
  //   DateTime dateTime = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     now.minute,
  //     now.second,
  //     0,
  //     0,
  //   );
  //   if (dateTime.isBefore(DateTime.now())) {
  //     dateTime = dateTime.add(const Duration(days: 1));
  //   }
  //
  //   final alarmSettings = AlarmSettings(
  //     id: id,
  //     dateTime: dateTime,
  //     loopAudio: loopAudio,
  //     vibrate: vibrate,
  //     volumeMax: volumeMax,
  //     notificationTitle: showNotification ? 'Alarm example' : null,
  //     notificationBody: showNotification ? 'Your alarm ($id) is ringing' : null,
  //     assetAudioPath: assetAudio,
  //     stopOnNotificationOpen: false,
  //   );
  //   return alarmSettings;
  // }

  Future<void> saveSettings() async{
    setState(() => loading = true);
    await UserPreferences().setFocusDuration(_newSettings['focusDuration']);
    await UserPreferences().setUnfocusDuration(_newSettings['unfocusDuration']);
    await UserPreferences().setRequireWalking(_newSettings['requireWalking']);
    await UserPreferences().setWalkingDistance(_newSettings['walkingDistance']);
    await UserPreferences().setLoopAudio(_newSettings['loopAudio']);
    await UserPreferences().setVibration(_newSettings['vibration']);
    await UserPreferences().setVolumeMax(_newSettings['volumeMax']);
    await UserPreferences().setShowNotification(_newSettings['showNotification']);
    await UserPreferences().setAssetAudionPath(_newSettings['assetAudionPath']);
    Navigator.pop(context, true);
    setState(() => loading = false);
  }
  // void saveAlarm() {
  //   setState(() => loading = true);
  //   Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
  //     if (res) Navigator.pop(context, true);
  //   });
  //   setState(() => loading = false);
  // }
  //
  // void deleteAlarm() {
  //   Alarm.stop(widget.alarmSettings!.id).then((res) {
  //     if (res) Navigator.pop(context, true);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: saveSettings,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                  "Save",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
          // Text(
          //   '${isToday() ? 'Today' : 'Tomorrow'} at',
          //   style: Theme.of(context)
          //       .textTheme
          //       .titleMedium!
          //       .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
          // ),
          // RawMaterialButton(
          //   onPressed: pickTime,
          //   fillColor: Colors.grey[200],
          //   child: Container(
          //     margin: const EdgeInsets.all(20),
          //     child: Text(
          //       selectedTime.format(context),
          //       style: Theme.of(context)
          //           .textTheme
          //           .displayMedium!
          //           .copyWith(color: Colors.blueAccent),
          //     ),
          //   ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: _newSettings['loopAudio'],
                onChanged: (value) => setState(() =>_newSettings['loopAudio'] = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vibrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: _newSettings['vibration'],
                onChanged: (value) => setState(() => _newSettings['vibration'] = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System volume max',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: _newSettings['volumeMax'],
                onChanged: (value) => setState(() => _newSettings['volumeMax'] = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show notification',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: _newSettings['showNotification'],
                onChanged: (value) => setState(() => _newSettings['showNotification'] = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sound',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: _newSettings['assetAudionPath'],
                items: const [
                  DropdownMenuItem<String>(
                    value: 'assets/marimba.mp3',
                    child: Text('Marimba'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/nokia.mp3',
                    child: Text('Nokia'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/mozart.mp3',
                    child: Text('Mozart'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/star_wars.mp3',
                    child: Text('Star Wars'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/one_piece.mp3',
                    child: Text('One Piece'),
                  ),
                ],
                onChanged: (value) => setState(() => _newSettings['assetAudionPath'] = value),
              ),
            ],
          ),
          // if (!creating)
          //   TextButton(
          //     onPressed: deleteAlarm,
          //     child: Text(
          //       'Delete Alarm',
          //       style: Theme.of(context)
          //           .textTheme
          //           .titleMedium!
          //           .copyWith(color: Colors.red),
          //     ),
          //   ),
          // const SizedBox(),
        ],
      ),
    );
  }
}