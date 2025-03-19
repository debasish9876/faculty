import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FacultyDashboard extends StatefulWidget {
  @override
  _FacultyDashboardState createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  late String facultyName;
  late String profileImageUrl;
  bool isLoading = true;

  final TextEditingController _chamberController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _officeHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFacultyData();
  }

  @override
  void dispose() {
    _chamberController.dispose();
    _infoController.dispose();
    _officeHoursController.dispose();
    super.dispose();
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
          'department': prefs.getString('department') ?? "Computer Science",
          'lastUpdated': ServerValue.timestamp,
          'officeHours': '',
          'info': ''
        });
      } else {
        // Load existing data into controllers
        Map<dynamic, dynamic> data = snapshot.value as Map;
        _chamberController.text = data['chamber'] ?? '';
        _infoController.text = data['info'] ?? '';
        _officeHoursController.text = data['officeHours'] ?? '';
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

  Future<void> _updateStatus(bool isPresent) async {
    try {
      final status = isPresent ? 'present' : 'absent';
      final now = DateTime.now().millisecondsSinceEpoch;

      // Update faculty status
      await database.child('faculty/$facultyName').update({
        'status': status,
        'lastUpdated': now
      });

      // Add to status history
      await database.child('statusHistory/$facultyName').push().set({
        'status': status,
        'timestamp': now
      });

      // Send notifications to students who are waiting for this faculty
      if (isPresent) {
        await _sendNotificationsToSubscribers();
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to ${isPresent ? 'Present' : 'Absent'}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  Future<void> _sendNotificationsToSubscribers() async {
    try {
      // Get all users who have subscribed to this faculty
      final snapshot = await database.child('notifications').get();
      if (!snapshot.exists) return;

      Map<dynamic, dynamic> users = snapshot.value as Map;

      // For each user who has subscribed to this faculty
      users.forEach((userId, facultySubscriptions) async {
        if (facultySubscriptions is Map &&
            facultySubscriptions.containsKey(facultyName) &&
            facultySubscriptions[facultyName]['active'] == true) {

          // In a real app, you would send a push notification here
          // For now, we'll just update the lastNotified timestamp
          await database.child('notifications/$userId/$facultyName').update({
            'lastNotified': ServerValue.timestamp
          });
        }
      });
    } catch (e) {
      print("Error sending notifications: $e");
    }
  }

  Future<void> _updateProfile() async {
    try {
      await database.child('faculty/$facultyName').update({
        'chamber': _chamberController.text,
        'info': _infoController.text,
        'officeHours': _officeHoursController.text,
        'lastUpdated': ServerValue.timestamp
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Faculty Dashboard"),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DatabaseEvent>(
        stream: database.child('faculty/$facultyName').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(child: Text("No data available"));
          }

          Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
          bool isPresent = data['status'] == 'present';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Image and Name
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.indigo.withOpacity(0.2),
                              backgroundImage: profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : null,
                              child: profileImageUrl.isEmpty
                                  ? Text(
                                facultyName.isNotEmpty ? facultyName[0] : "?",
                                style: TextStyle(fontSize: 30, color: Colors.indigo),
                              )
                                  : null,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? facultyName,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data['department'] ?? "Department",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPresent ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isPresent ? Colors.green : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isPresent ? Icons.check_circle : Icons.cancel,
                                          color: isPresent ? Colors.green : Colors.red,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          isPresent ? "Present" : "Absent",
                                          style: TextStyle(
                                            color: isPresent ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Status Toggle
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Update Your Status",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _updateStatus(true),
                                      icon: Icon(Icons.check_circle),
                                      label: Text("Mark as Present"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _updateStatus(false),
                                      icon: Icon(Icons.cancel),
                                      label: Text("Mark as Absent"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Students will be notified when you mark yourself as present.",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Profile Information Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profile Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Chamber
                        TextField(
                          controller: _chamberController,
                          decoration: InputDecoration(
                            labelText: "Chamber/Office",
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Office Hours
                        TextField(
                          controller: _officeHoursController,
                          decoration: InputDecoration(
                            labelText: "Office Hours",
                            prefixIcon: Icon(Icons.access_time),
                            hintText: "e.g., Mon-Wed 2-4 PM",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Additional Info
                        TextField(
                          controller: _infoController,
                          decoration: InputDecoration(
                            labelText: "Additional Information",
                            prefixIcon: Icon(Icons.info),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 16),

                        // Update Button
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text("Update Profile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Student Notifications Card
                StreamBuilder<DatabaseEvent>(
                  stream: database.child('notifications').onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                      return SizedBox.shrink();
                    }

                    Map<dynamic, dynamic> notificationsData = snapshot.data!.snapshot.value as Map;
                    int subscriberCount = 0;

                    // Count subscribers for this faculty
                    notificationsData.forEach((userId, facultySubscriptions) {
                      if (facultySubscriptions is Map &&
                          facultySubscriptions.containsKey(facultyName) &&
                          facultySubscriptions[facultyName]['active'] == true) {
                        subscriberCount++;
                      }
                    });

                    if (subscriberCount == 0) {
                      return SizedBox.shrink();
                    }

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Student Notifications",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.notifications_active, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  "$subscriberCount ${subscriberCount == 1 ? 'student is' : 'students are'} waiting for you",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "They will be notified when you mark yourself as present.",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),

                // Status History Card
                StreamBuilder<DatabaseEvent>(
                  stream: database.child('statusHistory/$facultyName').limitToLast(5).onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                      return SizedBox.shrink();
                    }

                    Map<dynamic, dynamic> historyData = snapshot.data!.snapshot.value as Map;
                    List<MapEntry<dynamic, dynamic>> historyList = historyData.entries.toList();

                    // Sort by timestamp (newest first)
                    historyList.sort((a, b) =>
                        (b.value['timestamp'] as int).compareTo(a.value['timestamp'] as int)
                    );

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recent Status Changes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            ...historyList.take(5).map((entry) {
                              final data = entry.value as Map;
                              final status = data['status'] as String;
                              final timestamp = data['timestamp'] as int;
                              final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                              final formattedDate = DateFormat('MMM d, h:mm a').format(date);

                              return Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      status == 'present' ? Icons.check_circle : Icons.cancel,
                                      color: status == 'present' ? Colors.green : Colors.red,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      status == 'present' ? "Present" : "Absent",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: status == 'present' ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}