import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Map order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState
    extends State<AdminOrderDetailScreen> {
  final controller = AdminController();

  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.order['status'];
  }

  Color getColor(String s) {
    switch (s) {
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
    final details = widget.order['orderdetail'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết đơn hàng"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ===== INFO =====
          Text("Order #${widget.order['order_id']}",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          SizedBox(height: 10),

          Text("Khách: ${widget.order['customer_id']}"),

          SizedBox(height: 10),

          // 🔥 STATUS + UPDATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: getColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: getColor(status),
                        fontWeight: FontWeight.bold)),
              ),

              DropdownButton(
                value: status,
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
                  setState(() => status = val!);

                  await controller.updateOrderStatus(
                      widget.order['order_id'], status);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã cập nhật trạng thái")),
                  );
                },
              )
            ],
          ),

          SizedBox(height: 10),

          Text("Thanh toán: ${widget.order['payment_method']}"),

          SizedBox(height: 10),

          Text("Tổng tiền: ${widget.order['total_amount']} VND",
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold)),

          Divider(height: 30),

          // ===== PRODUCT =====
          Text("Sản phẩm",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          SizedBox(height: 10),

          ...details.map<Widget>((d) {
            final product = d['product'] ?? {};

            final image = (product['image'] != null &&
                    product['image'].isNotEmpty)
                ? product['image'][0]['url']
                : '';

            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: Row(
                children: [
                  image != ''
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(image,
                              width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : Icon(Icons.image, size: 50),

                  SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'] ?? ''),
                        Text("SL: ${d['quantity']}"),
                        Text("${d['unit_price']} VND",
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList()
        ],
      ),
    );
  }
}