import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.dart'; // Thêm import này để gọi tới MainScreen
import 'user_orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final dynamic orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đặt hàng thành công"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text("Cảm ơn bạn đã đặt hàng!", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Mã đơn hàng: #$orderId", 
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 40),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                onPressed: () {
                  Get.off(() => UserOrdersScreen());
                },
                child: Text("Xem đơn hàng của tôi", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              
              SizedBox(height: 15),
              
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  side: BorderSide(color: Colors.orange, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                onPressed: () {
                  Get.offAll(() => MainScreen());
                },
                child: Text("Tiếp tục mua sắm", style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
