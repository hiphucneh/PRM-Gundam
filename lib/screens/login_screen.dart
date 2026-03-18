import 'package:flutter/material.dart';
import 'package:gundam_shop/main.dart';
import 'package:gundam_shop/screens/register_screen.dart';
import 'package:gundam_shop/screens/admin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final auth = AuthController();

  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide =
        Tween(begin: Offset(0, 0.3), end: Offset.zero).animate(_controller);

    _controller.forward();
  }

  // ================= LOGIN =================

  Future<void> login() async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nhập đầy đủ thông tin 😄")),
      );
      return;
    }

    setState(() => isLoading = true);

    final res = await auth.signIn(
      emailController.text.trim(),
      passController.text.trim(),
    );

    if (res == "SUCCESS") {
      try {
        final user = Supabase.instance.client.auth.currentUser;

        // 🔥 LẤY ROLE
        final roleData = await Supabase.instance.client
            .from('User')
            .select('role_id')
            .eq('user_id', user!.id)
            .single();

        final role = roleData['role_id'];

        setState(() => isLoading = false);

        // ================= PHÂN LUỒNG =================

        if (role == 1) {
          // 👉 ADMIN
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminScreen()),
          );
        } else {
          // 👉 USER
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi lấy role: $e")),
        );
      }
    } else {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res ?? "Lỗi đăng nhập")));
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.orange],
              ),
            ),
          ),

          // GUNDAM FLOAT
          Positioned(
            top: 80,
            left: 30,
            child: TweenAnimationBuilder(
              tween: Tween(begin: -10.0, end: 10.0),
              duration: Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Image.asset("assets/images/gundam.png", width: 120),
            ),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text("Gundam Shop",
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),

                        SizedBox(height: 30),

                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  labelText: "Email",
                                ),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                controller: passController,
                                obscureText: isObscure,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: "Password",
                                  suffixIcon: IconButton(
                                    icon: Icon(isObscure
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        isObscure = !isObscure;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text("Đăng nhập",
                                        style:
                                            TextStyle(color: Colors.white)),
                              ),

                              SizedBox(height: 10),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => RegisterScreen()),
                                  );
                                },
                                child: Text("Chưa có tài khoản? Đăng ký",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}