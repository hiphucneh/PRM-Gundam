import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = ProductController();

  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final data = await controller.getProducts();

      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gundam Shop"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : RefreshIndicator(
              onRefresh: loadProducts,
              child: ListView(
                children: [
                  buildBanner(),

                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("🔥 Sản phẩm nổi bật",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  products.isEmpty
                      ? Center(child: Text("Chưa có sản phẩm 😢"))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (_, index) {
                            final product = products[index];

                            final image = (product['Image'] != null &&
                                    product['Image'].isNotEmpty)
                                ? product['Image'][0]['url']
                                : "https://via.placeholder.com/150";

                            return buildProductCard(product, image);
                          },
                        )
                ],
              ),
            ),
    );
  }

  // ===== BANNER =====
  Widget buildBanner() {
    return Container(
      height: 160,
      margin: EdgeInsets.all(10),
      child: PageView(
        children: [
          bannerItem("🔥 Flash Sale", Colors.orange),
          bannerItem("⚡ Giảm 50%", Colors.deepOrange),
          bannerItem("🚀 Gundam mới", Colors.red),
        ],
      ),
    );
  }

  Widget bannerItem(String text, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [color, Colors.orangeAccent]),
      ),
      child: Center(
        child: Text(text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ===== CARD =====
  Widget buildProductCard(product, image) {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(image, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text(product['name'],
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 5),
                Text("${product['price']} VND",
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}