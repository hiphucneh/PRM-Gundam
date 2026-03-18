import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final auth = AuthController();

  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;

  bool hasUpper = false;
  bool hasSpecial = false;
  bool hasLength = false;

  void validatePassword(String value) {
    setState(() {
      hasUpper = value.contains(RegExp(r'[A-Z]'));
      hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasLength = value.length >= 8;
    });
  }

  Future<void> register() async {
    if (!(hasUpper && hasSpecial && hasLength)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password chưa đủ mạnh")),
      );
      return;
    }

    if (passController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu không khớp")),
      );
      return;
    }

    setState(() => isLoading = true);

    final res = await auth.signUp(
      emailController.text.trim(),
      passController.text.trim(),
      "User",
    );

    setState(() => isLoading = false);

    if (res == "SUCCESS") {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("🎉 Thành công"),
          content: Text("Tạo tài khoản thành công!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res ?? "Lỗi đăng ký")));
    }
  }

  Widget buildCheck(String text, bool ok) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel,
            color: ok ? Colors.green : Colors.red, size: 18),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND KHÁC LOGIN
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Register",
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
                            decoration:
                                InputDecoration(labelText: "Email"),
                          ),

                          SizedBox(height: 10),

                          TextField(
                            controller: passController,
                            obscureText: true,
                            onChanged: validatePassword,
                            decoration:
                                InputDecoration(labelText: "Password"),
                          ),

                          SizedBox(height: 10),

                          TextField(
                            controller: confirmController,
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Confirm Password"),
                          ),

                          SizedBox(height: 15),

                          buildCheck("≥ 8 ký tự", hasLength),
                          buildCheck("Có chữ hoa", hasUpper),
                          buildCheck("Có ký tự đặc biệt", hasSpecial),

                          SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white)
                                : Text("Đăng ký",
                                    style:
                                        TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}