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
  }) async {
    try {
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty. Cannot process payment.');
      }

      isProcessing.value = true;

      // 1. Insert into 'Orders' table and get the created order
      // Note: address/phone might better be stored in 'User' table since DB schema doesn't have shipping address in 'Orders' explicitly, or added to DB later.
      final orderResponse = await _client.from('Orders').insert({
        'customer_id': _userId,
        'total_amount': totalAmount,
        'status': 'Pending',
      }).select().single();

      final orderId = orderResponse['order_id'];

      // 2. Prepare OrderDetails from cart data
      final orderItemsData = cartItems.map((item) {
        final productId = item['product_id'];
        final quantity = item['quantity'];
        
        // Extract price from the nested joined Product table
        final productData = item['Product'] as Map<String, dynamic>;
        final price = productData['price']; 

        return {
          'order_id': orderId,
          'product_id': productId,
          'quantity': quantity,
          'unit_price': price,
        };
      }).toList();

      // Insert all mapped records into 'OrderDetail' table
      await _client.from('OrderDetail').insert(orderItemsData);

      // 3. Clear the 'CartItem' for this user
      final userCart = await _client.from('Cart').select('cart_id').eq('user_id', _userId).single();
      await _client.from('CartItem').delete().eq('cart_id', userCart['cart_id']);

      Get.snackbar('Payment Success', 'Your order has been placed successfully.');
      return true;

    } catch (e) {
      Get.snackbar('Payment Error', 'Failed to process payment: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
}