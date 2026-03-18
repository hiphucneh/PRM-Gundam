import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';

class AdminOrderScreen extends StatefulWidget {
  @override
  State<AdminOrderScreen> createState() =>
      _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final controller = AdminController();
  List orders = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await controller.getAllOrders();
    setState(() => orders = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý đơn hàng"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final o = orders[i];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Order #${o['order_id']}"),
              subtitle: Text("Status: ${o['status']}"),
              trailing: DropdownButton(
                value: o['status'],
                items: [
                  "Pending",
                  "Processing",
                  "Shipped",
                  "Delivered"
                ]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) async {
                  await controller.updateOrderStatus(
                      o['order_id'], val.toString());
                  load();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}