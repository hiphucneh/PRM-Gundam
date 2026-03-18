import 'package:supabase_flutter/supabase_flutter.dart';

class OrderController {
  final _client = Supabase.instance.client;
  String? get _userId => _client.auth.currentUser?.id;

  /// Tạo đơn hàng mới từ giỏ hàng (Billing)
  Future<void> createOrder(double totalAmount, List<dynamic> cartItems, String paymentMethod) async {
    if (_userId == null) throw Exception("Vui lòng đăng nhập!");
    try {
      final order = await _client.from('Orders').insert({
        'customer_id': _userId,
        'total_amount': totalAmount,
        'status': 'Pending', 
        'payment_method': paymentMethod
      }).select().single();

      final orderId = order['order_id'];

      final orderItemsData = cartItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'unit_price': item['Product']['price'], // Cần lấy giá từ Product
        };
      }).toList();

      await _client.from('OrderDetail').insert(orderItemsData);

      // Xóa các item trong giỏ hàng sau khi thanh toán thành công
      final cart = await _client.from('Cart').select('cart_id').eq('user_id', _userId!).single();
      await _client.from('CartItem').delete().eq('cart_id', cart['cart_id']);

    } catch (e) {
      throw Exception("Lỗi tạo đơn hàng: $e");
    }
  }

  /// Lấy lịch sử đơn hàng
  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    if (_userId == null) throw Exception("Vui lòng đăng nhập!");
    try {
      return await _client
          .from('Orders')
          .select('*, OrderDetail(*, Product(*, Image(*)))')
          .eq('customer_id', _userId!)
          .order('created_at', ascending: false);
    } catch (e) {
      throw Exception("Lỗi tải lịch sử đơn hàng: $e");
    }
  }
}