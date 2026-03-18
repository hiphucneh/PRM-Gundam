import 'package:flutter/material.dart';
import '../controllers/cart_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map product;
  final cart = CartController();

  ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX QUAN TRỌNG
    final image = (product['image'] != null && product['image'].isNotEmpty)
        ? product['image'][0]['url']
        : '';

    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: ListView( // ✅ FIX overflow + scroll
        children: [
          image != ''
              ? Image.network(image, height: 250, fit: BoxFit.cover)
              : Container(height: 250, color: Colors.grey[300]),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'],
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                SizedBox(height: 10),

                Text(
                  "${product['price']} VND",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 15),

                // ✅ THÊM DESCRIPTION
                Text("Mô tả:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(product['description'] ?? "Chưa có mô tả"),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(14),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      cart.addToCart(product['product_id'], 1);
                    },
                    child: Text("Add to Cart",
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}