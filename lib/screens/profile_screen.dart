import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),

              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person,
                    size: 50, color: Colors.orange),
              ),

              SizedBox(height: 10),

              Text(user?.email ?? "",
                  style: TextStyle(color: Colors.white, fontSize: 16)),

              SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout),
                label: Text("Đăng xuất"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}