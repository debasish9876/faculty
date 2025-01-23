import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add user to Firestore (used during registration)
  Future<void> addUser(String uid, String email, String role, String name) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'name': name,
      });
    } catch (e) {
      throw "Error adding user to Firestore: $e";
    }
  }

  // Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['role'];
      }
    } catch (e) {
      throw "Error fetching user role: $e";
    }
    return null;
  }

  // Get the faculty name from Firestore (faculty document)
  Future<String> getFacultyName(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        // Check if the user is a faculty and return the name
        if (userDoc['role'] == 'faculty') {
          return userDoc['name'] ?? 'Unknown Faculty'; // Return name or default if missing
        }
      }
      return 'Not a Faculty Member'; // Return default if not found
    } catch (e) {
      throw "Error fetching faculty name: $e";
    }
  }
}
