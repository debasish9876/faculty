import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyDetailsScreen extends StatelessWidget {
  final String department;

  FacultyDetailsScreen({required this.department});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$department Faculty")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('faculties')
            .where('department', isEqualTo: department)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text("Room: ${doc['room']}"),
                trailing: Chip(
                  label: Text(
                    doc['status'],
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: doc['status'] == "Available"
                      ? Colors.green
                      : (doc['status'] == "Busy" ? Colors.orange : Colors.red),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
