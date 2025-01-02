import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<CompassXEvent>(
          stream: CompassX.events,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('No data');
            final compass = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Heading: ${compass.heading}'),
                Text('Accuracy: ${compass.accuracy}'),
                Text('Should calibrate: ${compass.shouldCalibrate}'),
                Transform.rotate(
                  angle: compass.heading * math.pi / 180,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: MediaQuery.of(context).size.width - 80,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
