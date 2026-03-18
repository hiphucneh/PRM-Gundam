import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),

      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10)
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 👤 AVATAR
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange,
                child: Icon(Icons.admin_panel_settings,
                    size: 50, color: Colors.white),
              ),

              SizedBox(height: 20),

              // 📧 EMAIL
              Text(
                user?.email ?? "No Email",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 30),

              // 🔥 LOGOUT BUTTON
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await Supabase.instance.client.auth.signOut();

                    // 👉 FIX CHÍNH Ở ĐÂY
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi logout: $e")),
                    );
                  }
                },
                icon: Icon(Icons.logout),
                label: Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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