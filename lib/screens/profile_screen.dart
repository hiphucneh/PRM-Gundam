import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/profile_controller.dart';
import 'login_screen.dart';
import 'user_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final profileController = ProfileController();
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await profileController.getProfile();
      if (!mounted) return;
      setState(() {
        profile = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> showEditProfileDialog() async {
    final nameController = TextEditingController(
      text: (profile?['full_name'] ?? '').toString(),
    );
    final phoneController = TextEditingController(
      text: (profile?['phone'] ?? '').toString(),
    );
    final addressController = TextEditingController(
      text: (profile?['address'] ?? '').toString(),
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Chỉnh sửa thông tin"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Họ và tên"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "SĐT"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Địa chỉ"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await profileController.updateProfile(
                  fullName: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(ctx);
                await loadProfile();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Cập nhật thông tin thành công")),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi cập nhật hồ sơ: $e")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = (profile?['full_name'] ?? '').toString();
    final phone = (profile?['phone'] ?? '').toString();
    final address = (profile?['address'] ?? '').toString();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Colors.orange),
              ),
              SizedBox(height: 12),
              Text(
                displayName.isNotEmpty ? displayName : (user?.email ?? "Guest"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                user?.email ?? "",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 30),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.orange),
                        ),
                      )
                    : Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.call_outlined),
                            title: Text("SĐT"),
                            subtitle: Text(phone.isNotEmpty ? phone : "Chưa cập nhật"),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on_outlined),
                            title: Text("Địa chỉ"),
                            subtitle: Text(address.isNotEmpty ? address : "Chưa cập nhật"),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text("Chỉnh sửa thông tin tài khoản"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: showEditProfileDialog,
                          ),
                          ListTile(
                            leading: Icon(Icons.shopping_bag),
                            title: Text("Đơn hàng của tôi"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => UserOrdersScreen()),
                              );
                            },
                          ),
                        ],
                      ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(20),
                child: ElevatedButton.icon(
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
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
