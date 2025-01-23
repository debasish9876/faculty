import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Register User (for Students)
  Future<User?> register(String email, String password, String role, String name) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Add the user to Firestore with role and name
        await _firestoreService.addUser(user.uid, email, role, name);
        return user;
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Unknown error occurred during registration.";
    }
    return null;
  }

  // Sign In (For both Students and Faculty)
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Unknown error occurred during sign-in.";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
