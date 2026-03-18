import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';

class AdminProductScreen extends StatefulWidget {
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
    final data = await controller.getProducts(); // ⚠️ nhớ sửa controller
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  void addProduct() {
    final name = TextEditingController();
    final price = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("➕ Thêm sản phẩm"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: InputDecoration(labelText: "Tên")),
            TextField(controller: price, decoration: InputDecoration(labelText: "Giá")),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await controller.addProduct(
                name: name.text,
                categoryId: 1,
                price: double.parse(price.text),
                stock: 10,
                description: "",
                imageUrls: [],
              );
              Navigator.pop(context);
              load();
            },
            child: Text("Thêm"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addProduct,
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.orange),
              title: Text(p['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${p['price']} VND"),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await controller.deleteProduct(p['product_id']);
                  load();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}