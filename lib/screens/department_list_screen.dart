import 'package:flutter/material.dart';
import 'faculty_details_screen.dart';

class DepartmentListScreen extends StatelessWidget {
  final List<String> departments = ["Computer Science", "Electrical", "Mechanical", "Civil"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Departments")),
      body: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(departments[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FacultyDetailsScreen(department: departments[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
