import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import 'admin_order_detail_screen.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

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

  Color getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Processing":
        return Colors.blue;
      case "Shipped":
        return Colors.purple;
      case "Delivered":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý đơn hàng"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: orders.length,
        itemBuilder: (_, i) {
          final o = orders[i];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AdminOrderDetailScreen(order: o),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧾 ORDER ID + STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order #${o['order_id']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),

                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              getStatusColor(o['status']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          o['status'],
                          style: TextStyle(
                              color: getStatusColor(o['status']),
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 8),

                  // 👤 CUSTOMER
                  Text("Khách: ${o['customer_id'] ?? ''}"),

                  SizedBox(height: 5),

                  // 💰 TOTAL
                  Text("Tổng tiền: ${o['total_amount']} VND",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),

                  // 🔽 STATUS DROPDOWN
                  DropdownButton(
                    value: o['status'],
                    isExpanded: true,
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
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}