String formatSecondsToMinutes(int seconds) {
  var minutes = (seconds / 60).floor();
  var secondsLeft = seconds % 60;
  String secondsText = secondsLeft < 10 ? '0$secondsLeft' : secondsLeft.toString();
  return '$minutes:$secondsText';
}