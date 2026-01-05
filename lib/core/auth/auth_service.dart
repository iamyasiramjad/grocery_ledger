import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._() {
    print('Current user: ${_client.auth.currentUser}');
  }

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// Returns userId if logged in, otherwise null
  String? get currentUserId {
    return _client.auth.currentUser?.id;
  }

  bool get isLoggedIn {
    return currentUserId != null;
  }

  /// Google Sign-In (Native Flow)
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Initialize Google Sign In
      // serverClientId is required to get the idToken for Supabase
      final googleSignIn = GoogleSignIn(
        serverClientId: '401056083988-jvip1d9rgngf86ckagqlik0reogohvop.apps.googleusercontent.com',
      );
      
      // 2. Trigger the native picker
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      // 3. Obtain auth details (Tokens)
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw 'Missing ID Token from Google';
      }

      // 4. Send tokens to Supabase
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return currentUserId;
    } catch (e) {
      print('Native Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Sign out completely
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
