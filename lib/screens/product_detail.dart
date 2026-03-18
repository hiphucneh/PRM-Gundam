import 'package:flutter/material.dart';
import '../controllers/cart_controller.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map product;
  final cart = CartController();

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product['Image'] != null && product['Image'].isNotEmpty
        ? product['Image'][0]['url']
        : '';

    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: Column(
        children: [
          // IMAGE
          image != ''
              ? Image.network(image, height: 250, fit: BoxFit.cover)
              : Container(height: 250, color: Colors.grey[300]),

          // INFO
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'],
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                  "${product['price']} VND",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // BUTTON
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