import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final controller = AdminController();

  final name = TextEditingController();
  final price = TextEditingController();
  final description = TextEditingController();
  final image = TextEditingController();

  int? selectedCategory;
  List allCategories = [];
  List childCategories = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await controller.getCategories();

    setState(() {
      allCategories = data;
      childCategories =
          data.where((c) => c['parent_id'] != null).toList();
    });
  }

  String getParentName(int parentId) {
  final parent = allCategories.firstWhere(
    (c) => c['category_id'] == parentId,
    orElse: () => <String, dynamic>{}, // ✅ FIX
  );

  return parent.isNotEmpty ? parent['name'] : '';
}

  Future<void> submit() async {
    if (name.text.isEmpty ||
        price.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Nhập đủ thông tin")));
      return;
    }

    setState(() => isLoading = true);

    await controller.addProduct(
      name: name.text,
      categoryId: selectedCategory!,
      price: double.parse(price.text),
      stock: 10,
      description: description.text,
      imageUrls: image.text.isEmpty ? [] : [image.text],
    );

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
    return Scaffold(
      appBar: AppBar(title: Text("Thêm sản phẩm")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            input("Tên sản phẩm", name),
            input("Giá", price),
            input("Mô tả", description, maxLines: 3),
            input("Ảnh URL", image),

            DropdownButtonFormField<int>(
              value: selectedCategory,
              hint: Text("Chọn loại sản phẩm"),
              items: childCategories.map<DropdownMenuItem<int>>((c) {
                final parentName = getParentName(c['parent_id']);

                return DropdownMenuItem(
                  value: c['category_id'],
                  child: Text("$parentName → ${c['name']}"),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : submit,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("THÊM"),
            )
          ],
        ),
      ),
    );
  }
}