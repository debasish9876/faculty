import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacultyDashboard extends StatefulWidget {
  @override
  _FacultyDashboardState createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late String facultyName;
  late String profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFacultyData();
  }

  Future<void> _initializeFacultyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');
      facultyName = prefs.getString('facultyName') ?? "Unknown";
      profileImageUrl = prefs.getString('profileImage') ?? "";

      if (email == null) throw Exception("No email found in SharedPreferences");

      // Check if faculty data exists in Firebase
      final snapshot = await database.child('faculty/$facultyName').get();
      if (!snapshot.exists) {
        await database.child('faculty/$facultyName').set({
          'name': facultyName,
          'chamber': '',
          'status': 'absent',
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initializing data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : FutureBuilder<DataSnapshot>(
            future: database.child('faculty/$facultyName').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.value == null) {
                return Center(
                  child: Text(
                    "Error fetching data or no data found",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.data!.value as Map);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Faculty Dashboard",
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              facultyName,
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : AssetImage("assets/images/default_profile.png") as ImageProvider,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              TextField(
                                decoration: InputDecoration(labelText: "Infomation", border: OutlineInputBorder()),
                                controller: TextEditingController(text: data['chamber']),
                                onSubmitted: (value) {
                                  database.child('faculty/$facultyName').update({'chamber': value});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Status", style: TextStyle(fontSize: 18)),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: data['status'] == 'present' ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      data['status'] == 'present' ? "Present" : "Absent",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              SwitchListTile(
                                title: Text("Mark as Present"),
                                value: data['status'] == 'present',
                                onChanged: (value) async {
                                  try {
                                    await database.child('faculty/$facultyName').update({'status': value ? 'present' : 'absent'});
                                    setState(() {});
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating status: $e")));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Chamber", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              TextField(
                                decoration: InputDecoration(labelText: "Chamber", border: OutlineInputBorder()),
                                controller: TextEditingController(text: data['chamber']),
                                onSubmitted: (value) {
                                  database.child('faculty/$facultyName').update({'chamber': value});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
