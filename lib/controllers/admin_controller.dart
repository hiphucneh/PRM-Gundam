import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController {
  final _client = Supabase.instance.client;

  // ================= PRODUCT =================

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      return await _client.from('product').select();
    } catch (e) {
      throw Exception("Lỗi lấy sản phẩm: $e");
    }
  }

  Future<void> addProduct({
    required String name,
    required int categoryId,
    required double price,
    required int stock,
    required String description,
    required List<String> imageUrls,
  }) async {
    try {
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
        final imagesData = imageUrls.asMap().entries.map((entry) {
          return {
            'product_id': productId,
            'url': entry.value,
            'is_thumbnail': entry.key == 0,
          };
        }).toList();

        await _client.from('image').insert(imagesData);
      }
    } catch (e) {
      throw Exception("Lỗi thêm sản phẩm: $e");
    }
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> updates) async {
    try {
      await _client.from('product').update(updates).eq('product_id', productId);
    } catch (e) {
      throw Exception("Lỗi cập nhật sản phẩm: $e");
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _client.from('product').delete().eq('product_id', productId);
    } catch (e) {
      throw Exception("Lỗi xóa sản phẩm: $e");
    }
  }

  // ================= ORDER =================

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      return await _client
          .from('orders')
          .select('*, user(full_name, email), orderdetail(*)')
          .order('created_at', ascending: false);
    } catch (e) {
      throw Exception("Lỗi load order: $e");
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await _client
          .from('orders')
          .update({'status': status})
          .eq('order_id', orderId);
    } catch (e) {
      throw Exception("Lỗi update order: $e");
    }
  }

  // ================= DASHBOARD =================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final users = await _client.from('user').select('user_id');
      final orders = await _client.from('orders').select('order_id');
      final products = await _client.from('product').select('product_id');

      final revenueData = await _client
          .from('orders')
          .select('total_amount')
          .eq('status', 'Delivered');

      double totalRevenue = 0;
      for (var row in revenueData) {
        totalRevenue += (row['total_amount'] as num).toDouble();
      }

      return {
        'total_customers': users.length,
        'total_orders': orders.length,
        'total_products': products.length,
        'total_revenue': totalRevenue,
      };
    } catch (e) {
      throw Exception("Lỗi dashboard: $e");
    }
  }
}