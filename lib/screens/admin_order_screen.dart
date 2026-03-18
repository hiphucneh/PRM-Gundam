import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import 'package:get/get.dart';
import 'admin_order_detail.dart';

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

          return GestureDetector(
            onTap: () async {
              await Get.to(() => AdminOrderDetailScreen(order: o));
              load(); // Tải lại danh sách sau khi xem chi tiết (đề phòng xóa hoăc sửa)
            },
            child: Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text("Order #${o['order_id']}"),
                subtitle: Text("Status: ${o['status']}"),
                trailing: DropdownButton(
                  value: o['status'] ?? 'Pending',
                  items: [
                    "Pending",
                    "Processing",
                    "Shipped",
                    "Delivered",
                    "Cancelled"
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
            ),
          );
        },
      ),
    );
  }
}