import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ingredient_management_app/data/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === LOGO ===
              SizedBox(
                height: 300,
                width: 300,
                child: Image.asset(
                  "assets/img/awislogo.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 60),

              // === GOOGLE BUTTON ===
              InkWell(
                onTap: () async {
                  final user = await AuthService.signInWithGoogle();

                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login Berhasil")),
                    );

                    Navigator.pushReplacementNamed(context, "/home");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login dibatalkan / gagal")),
                    );
                  }
                },
                child: Container(
                  width: 260,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/google.svg",
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Sign In With Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
