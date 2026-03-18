import 'package:supabase_flutter/supabase_flutter.dart';

class ProductController {
  final _client = Supabase.instance.client;

  /// Lấy danh sách tất cả sản phẩm
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      return await _client
          .from('product') // ✅ FIX
          .select('*, image(*)'); // ✅ FIX
    } catch (e) {
      throw Exception("Lỗi tải danh sách sản phẩm: $e");
    }
  }

  /// Lấy chi tiết một sản phẩm
  Future<Map<String, dynamic>?> getProductById(int productId) async {
    try {
      return await _client
          .from('product') // ✅ FIX
          .select('*, image(*)') // ✅ FIX
          .eq('product_id', productId)
          .maybeSingle();
    } catch (e) {
      throw Exception("Lỗi tải chi tiết sản phẩm: $e");
    }
  }

  /// Lấy danh sách sản phẩm theo danh mục
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryName) async {
    try {
      return await _client
          .from('product') // ✅ FIX
          .select('*, category!inner(*), image(*)') // ✅ FIX
          .eq('category.name', categoryName); // ✅ FIX
    } catch (e) {
      throw Exception("Lỗi tải sản phẩm theo danh mục: $e");
    }
  }
}