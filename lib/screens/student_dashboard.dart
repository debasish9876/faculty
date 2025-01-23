import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DatabaseReference database = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(title: Text("Student Dashboard")),
      body: StreamBuilder<DatabaseEvent>(
        stream: database.child('faculty').onValue,  // Correct stream subscription
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: CircularProgressIndicator());
          }

          // Extract faculty data from the snapshot
          Map<String, dynamic> faculties = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          // Display the list of faculty members
          return ListView(
            children: faculties.entries.map((entry) {
              Map<String, dynamic> facultyData = Map<String, dynamic>.from(entry.value);
              return Card(
                child: ListTile(
                  title: Text(facultyData['name']),
                  subtitle: Text("Chamber: ${facultyData['chamber']}"),
                  trailing: Text(
                    facultyData['status'] == 'present' ? '🟢 Present' : '🔴 Absent',
                    style: TextStyle(
                      color: facultyData['status'] == 'present' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
