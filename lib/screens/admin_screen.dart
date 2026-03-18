import 'package:flutter/material.dart';
import 'admin_product_screen.dart';
import 'admin_order_screen.dart';
import 'admin_chat.dart';
import 'admin_account.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int index = 0;

  final screens = [
    AdminProductScreen(),
    AdminOrderScreen(),
    AdminChatScreen(),
    AdminAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADMIN PANEL"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange, Colors.orange],
            ),
          ),
        ),
      ),
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory), label: "Product"),
          NavigationDestination(icon: Icon(Icons.receipt), label: "Orders"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
          NavigationDestination(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}