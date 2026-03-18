import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';

class EditProductScreen extends StatefulWidget {
  final Map product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final controller = AdminController();

  late TextEditingController name;
  late TextEditingController price;
  late TextEditingController description;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.product['name']);
    price = TextEditingController(text: widget.product['price'].toString());
    description =
        TextEditingController(text: widget.product['description'] ?? "");
  }

  Future<void> update() async {
    setState(() => isLoading = true);

    await controller.updateProduct(
      widget.product['product_id'],
      {
        'name': name.text,
        'price': double.parse(price.text),
        'description': description.text,
      },
    );

    if (!mounted) return; // ✅ FIX QUAN TRỌNG

    Navigator.pop(context, true);
  }

  Widget input(String label, TextEditingController c,
      {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product['image'] as List?;
    final thumbnail =
        images != null && images.isNotEmpty ? images[0]['url'] : null;

    return Scaffold(
      appBar: AppBar(title: Text("Sửa sản phẩm")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🖼 ẢNH TO
            if (thumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  thumbnail,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            SizedBox(height: 15),

            input("Tên", name),
            input("Giá", price),
            input("Mô tả", description, maxLines: 3),

            ElevatedButton(
              onPressed: isLoading ? null : update,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("CẬP NHẬT"),
            )
          ],
        ),
      ),
    );
  }
}