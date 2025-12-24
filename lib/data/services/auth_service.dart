import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://localhost:8080";

  // Configure Google Sign In
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google and authenticate with backend
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Get Google authentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get ID token
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      print('Google Sign In successful');
      print('Email: ${googleUser.email}');
      print('Name: ${googleUser.displayName}');

      // Send ID token to backend for verification
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photo_url': googleUser.photoUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Save user data and token to local storage
        await _saveUserData(data);

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      print("ERROR LOGIN GOOGLE: $e");
      rethrow;
    }
  }

  /// Save user data to SharedPreferences
  static Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', data['data']['token'] ?? '');
    await prefs.setString('user_id', data['data']['user']['id'].toString());
    await prefs.setString('user_name', data['data']['user']['name'] ?? '');
    await prefs.setString('user_email', data['data']['user']['email'] ?? '');
    await prefs.setString(
      'user_photo',
      data['data']['user']['photo_url'] ?? '',
    );
    await prefs.setBool('is_logged_in', true);
  }

  /// Get saved user data
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'token': prefs.getString('token'),
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

  /// Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

  /// Verify token with backend
  static Future<bool> verifyToken() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("ERROR VERIFY TOKEN: $e");
      return false;
    }
  }

  /// Refresh token
  static Future<String?> refreshToken() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['data']['token'];

        // Save new token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);

        return newToken;
      }

      return null;
    } catch (e) {
      print("ERROR REFRESH TOKEN: $e");
      return null;
    }
  }
}
