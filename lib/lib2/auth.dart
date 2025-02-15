/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _fbAuth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<User> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  final UserCredential authResult =
      await _fbAuth.signInWithCredential(credential);
  final User user = authResult.user;
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);
  final User currentUser = _fbAuth.currentUser;
  assert(currentUser.uid == user.uid);
  return user;
}

// final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
// final GoogleSignInAuthentication googleSignInAuthentication =
//     await googleSignInAccount.authentication;
// final AuthCredential credential = GoogleAuthProvider.getCredential(
//     idToken: googleSignInAuthentication.idToken,
//     accessToken: googleSignInAuthentication.accessToken);
// final UserCredential authResult =
//     await _fbAuth.signInWithCredential(credential);
// final User user = authResult.user;
// assert(!user.isAnonymous);
// assert(await user.getIdToken() != null);
// final User currentUser = await _fbAuth.currentUser();
// assert(currentUser.uid == user.uid);
// return user;
*/
