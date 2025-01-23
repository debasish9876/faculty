import 'package:flutter/material.dart';

class FacultyCard extends StatelessWidget {
  final String name;
  final String room;
  final String status;

  FacultyCard({required this.name, required this.room, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text("Room: $room"),
        trailing: Chip(
          label: Text(
            status,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: status == "Available"
              ? Colors.green
              : (status == "Busy" ? Colors.orange : Colors.red),
        ),
      ),
    );
  }
}
