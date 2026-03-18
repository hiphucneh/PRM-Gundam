import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/profile_controller.dart';
import 'order_success_screen.dart';

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
  final profileController = ProfileController();

  String deliveryType = 'delivery'; // delivery | store
  bool isLoading = false;

  final _client = Supabase.instance.client;
  final cart = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  Future<void> _prefillFromProfile() async {
    try {
      final profile = await profileController.getProfile();
      if (!mounted || profile == null) return;

      name.text = (profile['full_name'] ?? '').toString();
      phone.text = (profile['phone'] ?? '').toString();
      address.text = (profile['address'] ?? '').toString();
    } catch (_) {}
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  double get total {
    double sum = 0;
    for (var item in widget.cartItems) {
      double price = 0;
      var rawPrice = item['product']['price'];
      
      if (rawPrice is num) {
        price = rawPrice.toDouble();
      } else if (rawPrice != null) {
        String priceStr = rawPrice.toString().replaceAll(',', '').replaceAll('.', '');
        price = double.tryParse(priceStr) ?? 0;
      }
      
      int qty = 1;
      var rawQty = item['quantity'];
      if (rawQty is num) {
        qty = rawQty.toInt();
      } else if (rawQty != null) {
        qty = int.tryParse(rawQty.toString()) ?? 1;
      }

      sum += price * qty;
    }
    return sum;
  }

  Future<void> checkout() async {
    try {
      final fullName = name.text.trim();
      final phoneNumber = phone.text.trim();
      final shippingAddress = address.text.trim();

      if (fullName.isEmpty || phoneNumber.isEmpty || (deliveryType == 'delivery' && shippingAddress.isEmpty)) {
        Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin");
        return;
      }

      setState(() => isLoading = true);

      try {
        await profileController.updateProfile(
          fullName: fullName,
          phone: phoneNumber,
          address: shippingAddress.isNotEmpty ? shippingAddress : null,
        );
      } catch (_) {}

      final userId = _client.auth.currentUser!.id;

      // ✅ tạo order, có thể lưu thêm name, phone, address tuỳ cấu trúc db
      // Cố gắng wrap trong try-catch để xem field có hợp lệ ko
      Map<String, dynamic> insertData = {
        'customer_id': userId,
        'total_amount': total,
        'status': 'Pending',
        'payment_method': deliveryType == 'delivery' ? 'COD' : 'Store Pickup',
      };

      final order = await _client.from('orders').insert(insertData).select().single();

      final orderId = order['order_id'];

      // ✅ tạo order detail
      for (var item in widget.cartItems) {
        double price = 0;
        var rawPrice = item['product']['price'];
        if (rawPrice is num) {
          price = rawPrice.toDouble();
        } else if (rawPrice != null) {
          String priceStr = rawPrice.toString().replaceAll(',', '').replaceAll('.', '');
          price = double.tryParse(priceStr) ?? 0;
        }

        int qty = 1;
        var rawQty = item['quantity'];
        if (rawQty is num) {
          qty = rawQty.toInt();
        } else if (rawQty != null) {
          qty = int.tryParse(rawQty.toString()) ?? 1;
        }

        await _client.from('orderdetail').insert({
          'order_id': orderId,
          'product_id': item['product']['product_id'],
          'quantity': qty,
          'unit_price': price,
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

      // Get.snackbar("Success", "Đặt hàng thành công 🎉"); // Ẩn snackbar
      
      if (!mounted) return;
      // Chuyển sang màn hình xác nhận đơn hàng thành công
      Get.off(() => OrderSuccessScreen(orderId: orderId));

    } catch (e) {
      Get.snackbar("Lỗi đặt hàng", e.toString(), duration: Duration(seconds: 5));
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