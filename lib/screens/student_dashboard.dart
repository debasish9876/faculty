import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  String searchQuery = '';
  String userId = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

      // Save the userId if it was just generated
      if (!prefs.containsKey('userId')) {
        await prefs.setString('userId', userId);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error initializing user ID: $e");
      setState(() {
        isLoading = false;
        userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  Future<void> _toggleNotification(String facultyName, bool isSubscribing) async {
    try {
      if (isSubscribing) {
        // Subscribe to notifications
        await database.child('notifications/$userId/$facultyName').set({
          'active': true,
          'subscribedAt': ServerValue.timestamp
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You'll be notified when $facultyName is available")),
        );
      } else {
        // Unsubscribe from notifications
        await database.child('notifications/$userId/$facultyName').update({
          'active': false
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Notification for $facultyName turned off")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating notification: $e")),
      );
    }
  }

  bool _isSubscribed(String facultyName, Map<dynamic, dynamic>? notifications) {
    if (notifications == null) return false;

    return notifications.containsKey(facultyName) &&
        notifications[facultyName] is Map &&
        notifications[facultyName]['active'] == true;
  }

  String _getLastUpdatedText(int timestamp) {
    final now = DateTime.now();
    final updateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(updateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(updateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Faculty Directory"),
        backgroundColor: Colors.indigo,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search faculty by name or chamber",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<DatabaseEvent>(
        stream: database.child('faculty').onValue,
        builder: (context, facultySnapshot) {
          if (facultySnapshot.connectionState == ConnectionState.waiting && !facultySnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!facultySnapshot.hasData || facultySnapshot.data?.snapshot.value == null) {
            return Center(child: Text("No faculty data available"));
          }

          return StreamBuilder<DatabaseEvent>(
            stream: database.child('notifications/$userId').onValue,
            builder: (context, notificationSnapshot) {
              Map<dynamic, dynamic>? notifications;

              if (notificationSnapshot.hasData && notificationSnapshot.data?.snapshot.value != null) {
                notifications = notificationSnapshot.data!.snapshot.value as Map;
              }

              Map<dynamic, dynamic> facultiesData = facultySnapshot.data!.snapshot.value as Map;
              List<MapEntry<dynamic, dynamic>> facultyList = facultiesData.entries.toList();

              // Apply search filter
              if (searchQuery.isNotEmpty) {
                facultyList = facultyList.where((entry) {
                  final faculty = entry.value as Map;
                  final name = faculty['name'] as String? ?? '';
                  final chamber = faculty['chamber'] as String? ?? '';

                  return name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      chamber.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();
              }

              // Sort by status (present first)
              facultyList.sort((a, b) {
                final statusA = (a.value as Map)['status'] as String? ?? '';
                final statusB = (b.value as Map)['status'] as String? ?? '';

                if (statusA == 'present' && statusB != 'present') {
                  return -1;
                } else if (statusA != 'present' && statusB == 'present') {
                  return 1;
                } else {
                  return 0;
                }
              });

              if (facultyList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No faculty members match your search",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: facultyList.length,
                itemBuilder: (context, index) {
                  final facultyKey = facultyList[index].key as String;
                  final faculty = facultyList[index].value as Map;
                  final name = faculty['name'] as String? ?? 'Unknown';
                  final chamber = faculty['chamber'] as String? ?? 'Not specified';
                  final status = faculty['status'] as String? ?? 'Unknown';
                  final isPresent = status == 'present';
                  final department = faculty['department'] as String? ?? '';
                  final officeHours = faculty['officeHours'] as String? ?? '';
                  final info = faculty['info'] as String? ?? '';
                  final lastUpdated = faculty['lastUpdated'] as int? ?? 0;

                  final isSubscribed = _isSubscribed(facultyKey, notifications);

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Show faculty details
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            maxChildSize: 0.9,
                            minChildSize: 0.5,
                            expand: false,
                            builder: (context, scrollController) {
                              return SingleChildScrollView(
                                controller: scrollController,
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 60,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.indigo.withOpacity(0.2),
                                            child: Text(
                                              name.isNotEmpty ? name[0] : "?",
                                              style: TextStyle(fontSize: 30, color: Colors.indigo),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  department,
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
                                                      if (lastUpdated > 0) ...[
                                                        SizedBox(width: 8),
                                                        Text(
                                                          "• ${_getLastUpdatedText(lastUpdated)}",
                                                          style: TextStyle(
                                                            color: Colors.grey.shade600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 24),
                                      _DetailItem(
                                        icon: Icons.location_on,
                                        title: "Chamber/Office",
                                        value: chamber,
                                      ),
                                      if (officeHours.isNotEmpty) ...[
                                        SizedBox(height: 16),
                                        _DetailItem(
                                          icon: Icons.access_time,
                                          title: "Office Hours",
                                          value: officeHours,
                                        ),
                                      ],
                                      if (info.isNotEmpty) ...[
                                        SizedBox(height: 16),
                                        _DetailItem(
                                          icon: Icons.info,
                                          title: "Additional Information",
                                          value: info,
                                        ),
                                      ],
                                      SizedBox(height: 24),
                                      if (!isPresent) ...[
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _toggleNotification(facultyKey, !isSubscribed);
                                          },
                                          icon: Icon(isSubscribed ? Icons.notifications_off : Icons.notifications_active),
                                          label: Text(isSubscribed ? "Turn Off Notifications" : "Notify When Available"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isSubscribed ? Colors.grey.shade700 : Colors.indigo,
                                            foregroundColor: Colors.white,
                                            minimumSize: Size(double.infinity, 48),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.indigo.withOpacity(0.2),
                              child: Text(
                                name.isNotEmpty ? name[0] : "?",
                                style: TextStyle(fontSize: 24, color: Colors.indigo),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        chamber,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (lastUpdated > 0) ...[
                                    Text(
                                      "Updated ${_getLastUpdatedText(lastUpdated)}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
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
                                      SizedBox(width: 4),
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
                                if (!isPresent && isSubscribed) ...[
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.amber,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.notifications_active,
                                          color: Colors.amber,
                                          size: 12,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          "Notifying",
                                          style: TextStyle(
                                            color: Colors.amber.shade800,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Helper widget for faculty details
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.indigo),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}