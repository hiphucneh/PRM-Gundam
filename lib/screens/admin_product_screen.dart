import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import 'admin_addproducts_screen.dart';
import 'admin_edit_product_screen.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final controller = AdminController();
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await controller.getProducts();

    if (!mounted) return; // ✅ FIX async context

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  Widget buildItem(Map p) {
    final images = p['image'] as List?;
    final thumbnail =
        images != null && images.isNotEmpty ? images[0]['url'] : null;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProductScreen(product: p),
          ),
        );

        if (!mounted) return; // ✅ FIX

        if (result == true) load();
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 ẢNH VUÔNG
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                child: thumbnail != null
                    ? Image.network(thumbnail, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 40),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Giúp Column ko lấn chiếm vùng của icon
                  children: [
                    Text(
                      p['name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "${p['price']} VND",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.only(right: 4, bottom: 4),
              alignment: Alignment.bottomRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.delete, color: Colors.red, size: 24),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Xác nhận xóa"),
                        content: Text("Bạn có chắc muốn xóa sản phẩm này không?"),
                        actions: [
                          TextButton(
                            child: Text("Hủy", style: TextStyle(color: Colors.grey)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text("Xóa", style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              Navigator.of(context).pop(); // đóng dialog
                              try {
                                await controller.deleteProduct(p['product_id']);
                                if (mounted) load();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Đã xóa sản phẩm"), duration: Duration(seconds: 2))
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Lỗi xóa sản phẩm: $e"), backgroundColor: Colors.red)
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Quản lý sản phẩm")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Quản lý sản phẩm")),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );

          if (!mounted) return; // ✅ FIX

          if (result == true) load();
        },
      ),

      // ✅ GRID VIEW 2 CỘT
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.58, // Tăng chiều dọc để ko bị giới hạn
        ),
        itemBuilder: (_, i) => buildItem(products[i]),
      ),
    );
  }
}