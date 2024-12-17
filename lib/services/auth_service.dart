// Implementing the Firebase authentication service
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Enable the user to create an account with our application
  // Majority of code from the Firebase documentation: https://firebase.google.com/docs/auth/flutter/password-auth
  Future<void> register(String emailAddress, String password) async {
    // Implement the registration logic here
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // TODO: Show a dialog or toast to let user know error
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // TODO: Show a dialog or toast to let user know error
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  // Majority of code from the Firebase documentation: https://firebase.google.com/docs/auth/flutter/password-auth
  Future<void> login(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // TODO: Show a dialog or toast to let user know error
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        // TODO: Show a dialog or toast to let user know error
        print('Wrong password provided for that user.');
      }
    }
  }

  // Majority of code from the Firebase documentation: https://firebase.google.com/docs/auth/flutter/password-auth
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
