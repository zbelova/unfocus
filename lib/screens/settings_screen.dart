
import 'package:flutter/material.dart';

import '../data/user_preferences.dart';

class SettingsScreen extends StatefulWidget {

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool loading = false;
  Map<String, dynamic> _newSettings = {};
  final TextEditingController _walkingDistanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newSettings = {
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
    _walkingDistanceController.text = _newSettings['walkingDistance'].round().toString();
  }


  @override
  void dispose() {
    _walkingDistanceController.dispose();
    super.dispose();
  }

  Future<void> saveSettings() async {
    setState(() => loading = true);
    await UserPreferences().setFocusDuration(_newSettings['focusDuration']);
    await UserPreferences().setUnfocusDuration(_newSettings['unfocusDuration']);
    await UserPreferences().setRequireWalking(_newSettings['requireWalking']);
    //await UserPreferences().setWalkingDistance(_newSettings['walkingDistance']);
    await UserPreferences().setWalkingDistance(double.parse(_walkingDistanceController.text));
    await UserPreferences().setLoopAudio(_newSettings['loopAudio']);
    await UserPreferences().setVibration(_newSettings['vibration']);
    await UserPreferences().setVolumeMax(_newSettings['volumeMax']);
    await UserPreferences().setShowNotification(_newSettings['showNotification']);
    await UserPreferences().setAssetAudionPath(_newSettings['assetAudionPath']);
    Navigator.pop(context, true);
    setState(() => loading = false);
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
                onPressed: () => Navigator.pop(context, false),
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
                  'Walking distance in steps required to unfocus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                width: 50,
                height: 40,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: _walkingDistanceController,
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
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
