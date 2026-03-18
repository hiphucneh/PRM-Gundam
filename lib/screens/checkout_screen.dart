import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

class CheckoutScreen extends StatefulWidget {
  final List cartItems;

  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  String deliveryType = 'delivery'; // delivery | store
  bool isLoading = false;

  final _client = Supabase.instance.client;
  final cart = Get.find<CartController>();

  double get total {
    double sum = 0;
    for (var item in widget.cartItems) {
      sum += (item['product']['price'] as num) *
          (item['quantity'] as int);
    }
    return sum;
  }

  Future<void> checkout() async {
    try {
      setState(() => isLoading = true);

      final userId = _client.auth.currentUser!.id;

      // ✅ tạo order
      final order = await _client.from('orders').insert({
        'customer_id': userId,
        'total_amount': total,
        'status': 'Pending',
        'payment_method': deliveryType == 'delivery'
            ? 'COD'
            : 'Store Pickup',
      }).select().single();

      final orderId = order['order_id'];

      // ✅ tạo order detail
      for (var item in widget.cartItems) {
        await _client.from('orderdetail').insert({
          'order_id': orderId,
          'product_id': item['product']['product_id'],
          'quantity': item['quantity'],
          'unit_price': item['product']['price'],
        });
      }

      // ✅ clear cart
      final cartData = await _client
          .from('cart')
          .select('cart_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (cartData != null) {
        await _client
            .from('cartitem')
            .delete()
            .eq('cart_id', cartData['cart_id']);
      }

      await cart.getCartItems();

      Get.snackbar("Success", "Đặt hàng thành công 🎉");

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      Get.snackbar("Error", "Checkout failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget input(String label, TextEditingController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thanh toán"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Thông tin khách hàng",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

          SizedBox(height: 10),

          input("Tên", name),
          input("SĐT", phone),

          if (deliveryType == 'delivery')
            input("Địa chỉ", address),

          SizedBox(height: 10),

          // 🚚 chọn loại giao hàng
          Text("Hình thức nhận hàng"),

          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  value: 'delivery',
                  groupValue: deliveryType,
                  title: Text("Giao hàng"),
                  onChanged: (v) {
                    setState(() => deliveryType = v!);
                  },
                ),
              ),
              Expanded(
                child: RadioListTile(
                  value: 'store',
                  groupValue: deliveryType,
                  title: Text("Nhận tại shop"),
                  onChanged: (v) {
                    setState(() => deliveryType = v!);
                  },
                ),
              ),
            ],
          ),

          Divider(),

          // 🛒 tổng tiền
          Text("Tổng tiền: ${total.toStringAsFixed(0)} VND",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.all(14),
            ),
            onPressed: isLoading ? null : checkout,
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text("ĐẶT HÀNG",
                    style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}