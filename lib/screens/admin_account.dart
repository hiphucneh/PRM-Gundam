import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange,
            child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
          ),

          SizedBox(height: 20),

          Text(
            user?.email ?? "",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
            icon: Icon(Icons.logout),
            label: Text("Đăng xuất"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
          )
        ],
      ),
    );
  }
}