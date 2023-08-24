import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.inversePrimary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Focus'),
          ),
          body:  Center(
            child: Column(
              children: [
                Text('Focus'),
                RawMaterialButton(
                  onPressed: () {
                    Alarm.stopAll()
                        .then((_) => Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false));
                  },
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
