import 'package:google_sign_in/google_sign_in.dart';
import 'package:ingredient_management_app/config/google_client_id.dart';

class AuthService {
  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: GoogleClientID.googleClientId,
        scopes: ["email", "profile"],
      );

      final user = await googleSignIn.signIn();
      return user;
    } catch (e) {
      print("ERROR LOGIN GOOGLE: $e");
      return null;
    }
  }
}
