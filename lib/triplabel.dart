import 'package:flutter/material.dart';
import 'trip.dart';

class TripLabel extends StatelessWidget {
  final String trip;

  const TripLabel({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Trip(tripName: trip)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purpleAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Text(
          trip,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
