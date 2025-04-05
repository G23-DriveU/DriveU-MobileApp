// Implementing the Firebase authentication service
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Enable the user to create an account with our application
  // Majority of code from the Firebase documentation: https://firebase.google.com/docs/auth/flutter/password-auth
  Future<String?> register(String emailAddress, String password) async {
    // Implement the registration logic here
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // Successful register, now onto email verification
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return e.code.toString();
      } else if (e.code == 'email-already-in-use') {
        return e.code.toString();
      }
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  // Majority of code from the Firebase documentation: https://firebase.google.com/docs/auth/flutter/password-auth
  Future<String?> login(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      return null;
    } catch (e) {
      print("Debugging error $e");
      return e.toString();
    }
  }

  // Majority of code from the Firebase documentation: https://firebase.google.com/docs/auth/flutter/password-auth
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Check to see if an entered email is already in use
  Future<bool> checkEmail(String email) async {
    try {
      final user =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return user.isNotEmpty;
    } catch (e) {
      print("Debugging error $e");
      return false;
    }
  }

  // Enable the user to reset their email
  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
