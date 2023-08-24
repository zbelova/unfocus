import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:unfocus/screens/home_screen.dart';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "You alarm (${alarmSettings.id}) is ringing...",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                          now.second,
                          now.millisecond,
                        ).add(const Duration(seconds: 10)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    "Unfocus",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                // RawMaterialButton(
                //   onPressed: () {
                //     Alarm.stopAll()
                //         .then((_) => Navigator.pushAndRemoveUntil(context,
                //             MaterialPageRoute(builder: (_) => const HomePage()),
                //             (route) => false));
                //   },
                //   child: Text(
                //     "Stop",
                //     style: Theme.of(context).textTheme.titleLarge,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}