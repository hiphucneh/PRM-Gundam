import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import 'admin_addproducts_screen.dart';

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
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  Widget buildItem(Map p) {
    final images = p['image'] as List?;
    final thumbnail =
        images != null && images.isNotEmpty ? images[0]['url'] : null;

    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: thumbnail != null
            ? Image.network(thumbnail, width: 50)
            : Icon(Icons.image),

        title: Text(p['name']),
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
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

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

          if (result == true) load();
        },
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: products.length,
        itemBuilder: (_, i) => buildItem(products[i]),
      ),
    );
  }
}