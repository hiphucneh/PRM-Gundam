import 'package:flutter/material.dart';
import '../controllers/checkout_controller.dart';

class CheckoutScreen extends StatefulWidget {
  final List cartItems;

  CheckoutScreen({required this.cartItems});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final controller = CheckoutController();

  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  double get total {
    double sum = 0;
    for (var item in widget.cartItems) {
      sum += (item['quantity'] * item['Product']['price']);
    }
    return sum;
  }

  Future<void> checkout() async {
    final success = await controller.processPayment(
      totalAmount: total,
      address: addressController.text,
      phone: phoneController.text,
      cartItems: List<Map<String, dynamic>>.from(widget.cartItems),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thanh toán")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Địa chỉ",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "SĐT",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    title: Text(item['Product']['name']),
                    subtitle: Text("x${item['quantity']}"),
                    trailing: Text(
                      "${item['Product']['price'] * item['quantity']}",
                    ),
                  );
                },
              ),
            ),

            Text(
              "Tổng: $total VND",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: checkout,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
              child: Text("Đặt hàng",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}