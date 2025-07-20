import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'tripdialog.dart';
import 'triplabel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  List<String> trips = [];
  final TextEditingController biocontroller = TextEditingController();
  final String hintText = "Enter your trip name";

  @override
  void initState() {
    super.initState();
    loadTrips();
  }

  Future<void> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTrips = prefs.getStringList('trips') ?? [];
    setState(() {
      trips = savedTrips;
    });
  }

  Future<void> saveTrip(String name) async {
    final prefs = await SharedPreferences.getInstance();
    trips.add(name);
    await prefs.setStringList('trips', trips);
    setState(() {});
  }

  Future<void> deleteTrip(String name) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove trip name from shared prefs
    trips.remove(name);
    await prefs.setStringList('trips', trips);

    // Delete associated folder
    final directory = await getApplicationDocumentsDirectory();
    final tripFolder = Directory('${directory.path}/$name');
    if (await tripFolder.exists()) {
      await tripFolder.delete(recursive: true);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    onSubmit() {
      final name = biocontroller.text.trim();
      if (name.isNotEmpty && !trips.contains(name)) {
        saveTrip(name);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: trips.isEmpty
          ? const Center(child: Text("No trips yet."))
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: TripLabel(trip: trips[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Delete Trip"),
                            content: Text(
                              "Are you sure you want to delete '${trips[index]}'?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteTrip(trips[index]);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Myinputalertbox(
              biocontroller: biocontroller,
              hintText: hintText,
              onSubmit: onSubmit,
              submittext: "Submit",
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
