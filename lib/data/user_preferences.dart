import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  //создание переменной для сохранения preferences
  static SharedPreferences? _preferences;

  //инициализация preferences
  Future init() async => _preferences = await SharedPreferences.getInstance();

  //функция очистки сохраненных данных пользователя - вызывать если надо сбросить данные
  Future clear() async => _preferences?.clear();

  //Future setTimers(Map<String, String> timers) async => await _preferences?.('timers', timers);

  // List<String> getTimers() => _preferences?.getStringList('timers') ?? [];
  //
  // Future setPreferences(List<String> preferences) async => await _preferences?.setStringList('preferences', preferences);
  //
  // List<String> getPreferences() => _preferences?.getStringList('preferences') ?? [];

  double getFocusDuration()  => _preferences?.getDouble('focusDuration') ?? 40;

  Future setFocusDuration(double focusTimer) async => await _preferences?.setDouble('focusDuration', focusTimer);

  double getUnfocusDuration()  => _preferences?.getDouble('unfocusDuration') ?? 10;

  Future setUnfocusDuration(double unfocusTimer) async => await _preferences?.setDouble('unfocusDuration', unfocusTimer);

  bool getRequireWalking()  => _preferences?.getBool('requireWalking') ?? true;

  Future setRequireWalking(bool reqireWalkings) async => await _preferences?.setBool('requireWalking', reqireWalkings);

  double getWalkingDuration()  => _preferences?.getDouble('walkingDuration') ?? 15;

  Future setWalkingDuration(double walkingDuration) async => await _preferences?.setDouble('walkingDuration', walkingDuration);

  bool getLoopAudio()  => _preferences?.getBool('loopAudio') ?? true;

  Future setLoopAudio(bool loopAudio) async => await _preferences?.setBool('loopAudio', loopAudio);

  bool getVibration() => _preferences?.getBool('vibration') ?? false;

  Future setVibration(bool vibration) async => await _preferences?.setBool('vibration', vibration);

  bool getVolumeMax()  => _preferences?.getBool('volumeMax') ?? true;

  Future setVolumeMax(bool volumeMax) async => await _preferences?.setBool('volumeMax', volumeMax);

  bool getShowNotification() => _preferences?.getBool('showNotification') ?? true;

  Future setShowNotification(bool showNotification) async => await _preferences?.setBool('showNotification', showNotification);

  String getAssetAudionPath() => _preferences?.getString('assetAudionPath') ?? 'assets/meditation.mp3';

  Future setAssetAudionPath(String assetAudionPath) async => await _preferences?.setString('assetAudionPath', assetAudionPath);
}
