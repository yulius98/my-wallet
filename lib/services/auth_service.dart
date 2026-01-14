import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';


class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<User?> signInWithGoogle() async {
    try {
      // Clear any previous sign-in state
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('User cancelled Google Sign-In');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      debugPrint('Successfully signed in: ${userCredential.user?.email}');
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      if (e.toString().contains('ApiException: 10')) {
        debugPrint('DEVELOPER_ERROR: SHA-1 fingerprint not configured in Firebase Console');
        throw Exception('Konfigurasi aplikasi belum lengkap. Silakan tambahkan SHA-1 fingerprint di Firebase Console: FC:F3:05:CF:5B:24:94:B4:48:67:8D:A6:47:B1:68:F3:F7:1A:C2:71');
      }
      rethrow;
    }
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
