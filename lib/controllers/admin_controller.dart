import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController {
  final _client = Supabase.instance.client;

  // ================= PRODUCT =================

  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _client
        .from('product')
        .select('*, image(*)')
        .order('product_id', ascending: false);
  }

  Future<void> addProduct({
    required String name,
    required int categoryId,
    required double price,
    required int stock,
    required String description,
    required List<String> imageUrls,
  }) async {
    final product = await _client.from('product').insert({
      'name': name,
      'category_id': categoryId,
      'price': price,
      'stock': stock,
      'description': description,
      'status': 'Active',
    }).select().single();

    final productId = product['product_id'];

    if (imageUrls.isNotEmpty) {
      final imagesData = imageUrls.asMap().entries.map((e) {
        return {
          'product_id': productId,
          'url': e.value,
          'is_thumbnail': e.key == 0,
        };
      }).toList();

      await _client.from('image').insert(imagesData);
    }
  }

  Future<void> deleteProduct(int productId) async {
    await _client.from('product').delete().eq('product_id', productId);
  }

  // ================= CATEGORY =================

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _client.from('category').select();
  }

  // ================= ORDER =================

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    return await _client
        .from('orders')
        .select('*, customer_id(full_name, email), orderdetail(*)')
        .order('created_at', ascending: false);
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await _client
        .from('orders')
        .update({'status': status})
        .eq('order_id', orderId);
  }
}