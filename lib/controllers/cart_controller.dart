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
    // Safely check if user is logged in before fetching on init
    if (_client.auth.currentUser != null) {
      getCartItems();
    }
  }

  Future<void> getCartItems() async {
    try {
      isLoading.value = true;
      // Get the user's cart first
      final cart = await _client.from('Cart').select('cart_id').eq('user_id', _userId).maybeSingle();
      if (cart == null) {
        cartItems.clear();
        return;
      }
      
      final response = await _client
          .from('CartItem')
          .select('*, Product(*, Image(*))')
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
      // Triggers automatically create a cart for new users, so we can assume it exists, or create one if not just in case
      var cart = await _client.from('Cart').select('cart_id').eq('user_id', _userId).maybeSingle();
      if (cart == null) {
        cart = await _client.from('Cart').insert({'user_id': _userId}).select('cart_id').single();
      }
      final cartId = cart['cart_id'];

      final existingItem = await _client
          .from('CartItem')
          .select()
          .eq('cart_id', cartId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existingItem != null) {
        // Update existing quantity
        final newQuantity = (existingItem['quantity'] as int) + quantity;
        await _client
            .from('CartItem')
            .update({'quantity': newQuantity})
            .eq('item_id', existingItem['item_id']);
      } else {
        // Insert new record
        await _client.from('CartItem').insert({
          'cart_id': cartId,
          'product_id': productId,
          'quantity': quantity,
        });
      }
      
      await getCartItems(); // Refresh the cart
      Get.snackbar('Success', 'Item added to cart');
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
          .from('CartItem')
          .delete()
          .eq('item_id', cartItemId);
          
      await getCartItems(); // Refresh the cart
      Get.snackbar('Success', 'Item removed from cart');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove item from cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkCartHasItems() async {
    try {
      final cart = await _client.from('Cart').select('cart_id').eq('user_id', _userId).maybeSingle();
      if (cart == null) return false;

      final response = await _client
          .from('CartItem')
          .select('item_id')
          .eq('cart_id', cart['cart_id'])
          .limit(1);
          
      return response.isNotEmpty;
    } catch (e) {
      // Return false if user not logged in or query fails
      return false;
    }
  }
}