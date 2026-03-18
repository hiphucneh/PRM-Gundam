import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  final _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('User not authenticated');
    return id;
  }

  var cartItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_client.auth.currentUser != null) {
      getCartItems();
    }
  }

  Future<void> getCartItems() async {
    try {
      isLoading.value = true;

      final cart = await _client
          .from('cart') // ✅ FIX
          .select('cart_id')
          .eq('user_id', _userId)
          .maybeSingle();

      if (cart == null) {
        cartItems.clear();
        return;
      }

      final response = await _client
          .from('cartitem') // ✅ FIX
          .select('*, product(*, image(*))') // ✅ FIX
          .eq('cart_id', cart['cart_id']);

      cartItems.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cart items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      isLoading.value = true;

      var cart = await _client
          .from('cart')
          .select('cart_id')
          .eq('user_id', _userId)
          .maybeSingle();

      if (cart == null) {
        cart = await _client
            .from('cart')
            .insert({'user_id': _userId})
            .select('cart_id')
            .single();
      }

      final cartId = cart['cart_id'];

      final existingItem = await _client
          .from('cartitem')
          .select()
          .eq('cart_id', cartId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existingItem != null) {
        final newQuantity = (existingItem['quantity'] as int) + quantity;

        await _client
            .from('cartitem')
            .update({'quantity': newQuantity})
            .eq('item_id', existingItem['item_id']);
      } else {
        await _client.from('cartitem').insert({
          'cart_id': cartId,
          'product_id': productId,
          'quantity': quantity,
        });
      }

      await getCartItems();

      Get.snackbar('Success', 'Đã thêm vào giỏ 🛒');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item to cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      isLoading.value = true;

      await _client
          .from('cartitem') // ✅ FIX
          .delete()
          .eq('item_id', cartItemId);

      await getCartItems();

      Get.snackbar('Success', 'Đã xóa sản phẩm');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove item: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkCartHasItems() async {
    try {
      final cart = await _client
          .from('cart')
          .select('cart_id')
          .eq('user_id', _userId)
          .maybeSingle();

      if (cart == null) return false;

      final response = await _client
          .from('cartitem')
          .select('item_id')
          .eq('cart_id', cart['cart_id'])
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}