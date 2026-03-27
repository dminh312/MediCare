import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medicare/logic/models/user_model.dart' as model;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, String phoneNumber) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;

      if (user != null) {
        // Update display name in Firebase Auth
        await user.updateDisplayName(name);

        // Create a new user document in Firestore
        final userModel = model.UserModel(
          uid: user.uid,
          email: email,
          displayName: name,
          phoneNumber: phoneNumber,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          preferences: model.UserPreferences(),
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore());
        
        // Dispatch verification email immediately
        await user.sendEmailVerification();
      }
      
      return user;
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception to be handled by the ViewModel
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // Create a new user document if it doesn't exist
          final userModel = model.UserModel(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName!,
            photoURL: user.photoURL,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            preferences: model.UserPreferences(),
          );
          await _firestore.collection('users').doc(user.uid).set(userModel.toFirestore());
        }
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
