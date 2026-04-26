import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medicare/logic/models/user_model.dart' as model;
import 'package:medicare/logic/services/network_service.dart';
import 'package:medicare/logic/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    return await NetworkService().runNetworkTask(() async {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore());

        // Dispatch verification email immediately
        await user.sendEmailVerification();
      }

      return user;
    });
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await NetworkService().runNetworkTask(() async {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    });
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    return await NetworkService().runNetworkTask(() async {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
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
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toFirestore());
        }
      }

      return user;
    });
  }

  // Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    return await NetworkService().runNetworkTask(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  // Sign out
  Future<void> signOut() async {
    return await NetworkService().runNetworkTask(() async {
      await _auth.signOut();
      await _googleSignIn.signOut();
      
      // Clear app-level preferences that are tied to the user to trigger permissions again
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(OnboardingService.completedKey);
        await prefs.remove(OnboardingService.flowVersionKey);
        await prefs.remove('health_connect_connected');
        await prefs.remove('chatbot_save_history_preference');
        await prefs.remove('email');
        await prefs.remove('password');
      } catch (e) {
        // Ignore failure to access shared preferences during signout
      }
    }, timeoutSeconds: 5);
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    return await NetworkService().runNetworkTask(() async {
      User? user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Delete user document in Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete the user from Firebase Auth
        await user.delete();

        // Sign out to clear any remaining auth state (google sign in)
        await _googleSignIn.signOut();

        // Clear all local preferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
        } catch (e) {
          // Ignore failure
        }
      }
    });
  }
}
