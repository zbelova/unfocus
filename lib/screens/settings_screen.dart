import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/user_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool loading = false;
  Map<String, dynamic> _newSettings = {};
  final TextEditingController _walkingDurationController = TextEditingController();

  AudioPlayer audioPlayer = AudioPlayer();

  final List _music = [
    [
      'Meditation',
      'assets/meditation.mp3',
    ],
    [
      'Trapsoul',
      'assets/trapsoul.mp3',
    ],
    [
      'R&B',
      'assets/rb.mp3',
    ],
    [
      'Dance 1',
      'assets/dance1.mp3',
    ],
    [
      'Dance 2',
      'assets/dance2.mp3',
    ]
  ];

  @override
  void initState() {
    super.initState();
    _newSettings = {
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
    _walkingDurationController.text = _newSettings['walkingDuration'].round().toString();
  }

  @override
  void dispose() {
    _walkingDurationController.dispose();
    super.dispose();
  }

  Future<void> saveSettings() async {
    stopAudio();
    setState(() => loading = true);
    await UserPreferences().setFocusDuration(_newSettings['focusDuration']);
    await UserPreferences().setUnfocusDuration(_newSettings['unfocusDuration']);
    await UserPreferences().setRequireWalking(_newSettings['requireWalking']);
    await UserPreferences().setWalkingDuration(double.parse(_walkingDurationController.text));
    await UserPreferences().setLoopAudio(_newSettings['loopAudio']);
    await UserPreferences().setVibration(_newSettings['vibration']);
    await UserPreferences().setVolumeMax(_newSettings['volumeMax']);
    await UserPreferences().setShowNotification(_newSettings['showNotification']);
    await UserPreferences().setAssetAudionPath(_newSettings['assetAudionPath']);
    Navigator.pop(context, true);
    setState(() => loading = false);
  }

  void playAudio() async {
    String fileName = _newSettings['assetAudionPath'].split('/').last;
    audioPlayer.play(
      AssetSource(fileName),
      volume: 1,
    );
  }

  void stopAudio() async {
    audioPlayer.stop();
  }

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
                onPressed: () {
                  stopAudio();
                  Navigator.pop(context, false);
                },
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.blueAccent),
                ),
              ),
              TextButton(
                onPressed: saveSettings,
                child: loading
                    ? const CircularProgressIndicator()
                    : Text(
                        "Save",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.blueAccent),
                      ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 250,
                child: Text(
                  //overflow: TextOverflow.clip,
                  maxLines: 3,
                  'Walking duration in seconds required to unfocus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                width: 50,
                height: 40,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: _walkingDurationController,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loop alarm audio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: _newSettings['loopAudio'],
                onChanged: (value) => setState(() => _newSettings['loopAudio'] = value),
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
              IconButton(onPressed: playAudio, icon: Icon(Icons.play_arrow)),
              IconButton(onPressed: stopAudio, icon: Icon(Icons.stop)),
              DropdownButton(
                value: _newSettings['assetAudionPath'],
                //onTap: () {},
                items: _music
                    .map((e) => DropdownMenuItem(
                          value: e[1],
                          child: Text(e[0]),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _newSettings['assetAudionPath'] = value),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
