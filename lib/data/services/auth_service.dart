import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Configure Google Sign In (TANPA serverClientId)
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google (Frontend only)
  /// Sign in with Google (Frontend only) - Always show account picker
  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      // TAMBAHKAN INI: Sign out dulu untuk memaksa pemilihan akun
      await _googleSignIn.signOut();

      // Trigger Google Sign In (akan selalu muncul dialog pemilihan akun)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      print('Google Sign In successful');
      print('Email: ${googleUser.email}');
      print('Name: ${googleUser.displayName}');
      print('Photo: ${googleUser.photoUrl}');

      // Save user data to local storage
      await _saveUserData(googleUser);

      return googleUser;
    } catch (e) {
      print("ERROR LOGIN GOOGLE: $e");
      rethrow;
    }
  }

  /// Save user data to SharedPreferences
  static Future<void> _saveUserData(GoogleSignInAccount user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.displayName ?? '');
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_photo', user.photoUrl ?? '');
    await prefs.setBool('is_logged_in', true);
  }

  /// Get saved user data
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'user_id': prefs.getString('user_id'),
      'user_name': prefs.getString('user_name'),
      'user_email': prefs.getString('user_email'),
      'user_photo': prefs.getString('user_photo'),
    };
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Get saved email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('Sign out successful');
    } catch (e) {
      print("ERROR SIGN OUT: $e");
      rethrow;
    }
  }

  /// Check if email is allowed (contoh pengecekan email)
  static bool isEmailAllowed(String email) {
    // Daftar email yang diizinkan
    final allowedEmails = [
      'xxspanzie@gmail.com',
      'ilhammhafidzz@gmail.com',
      '20220810042@uniku.ac.id',
      '20220810039@uniku.ac.id',
      '20220810030@uniku.ac.id',
    ];

    // Atau cek domain
    // return email.endsWith('@example.com');

    return allowedEmails.contains(email.toLowerCase());
  }
}
