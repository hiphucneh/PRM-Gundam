import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutController extends GetxController {
  final _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('User not authenticated');
    return id;
  }

  var isProcessing = false.obs;

  Future<bool> processPayment({
    required double totalAmount,
    required String address,
    required String phone,
    required List<Map<String, dynamic>> cartItems,
    required String deliveryType, // ✅ thêm
  }) async {
    try {
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      isProcessing.value = true;

      // ✅ 1. CREATE ORDER
      final orderResponse = await _client
          .from('orders') // ✅ FIX
          .insert({
        'customer_id': _userId,
        'total_amount': totalAmount,
        'status': 'Pending',
        'payment_method':
            deliveryType == 'delivery' ? 'COD' : 'Store Pickup',
      })
          .select()
          .single();

      final orderId = orderResponse['order_id'];

      // ✅ 2. ORDER DETAILS
      final orderItemsData = cartItems.map((item) {
        final product = item['product']; // ✅ FIX

        return {
          'order_id': orderId,
          'product_id': product['product_id'],
          'quantity': item['quantity'],
          'unit_price': product['price'],
        };
      }).toList();

      await _client
          .from('orderdetail') // ✅ FIX
          .insert(orderItemsData);

      // ✅ 3. CLEAR CART
      final userCart = await _client
          .from('cart') // ✅ FIX
          .select('cart_id')
          .eq('user_id', _userId)
          .maybeSingle();

      if (userCart != null) {
        await _client
            .from('cartitem') // ✅ FIX
            .delete()
            .eq('cart_id', userCart['cart_id']);
      }

      Get.snackbar(
        'Success',
        'Đặt hàng thành công 🎉',
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Thanh toán thất bại: $e',
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}