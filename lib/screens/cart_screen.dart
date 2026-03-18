import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final cart = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Giỏ hàng"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (cart.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (cart.cartItems.isEmpty) {
          return Center(child: Text("Giỏ hàng trống 😢"));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cart.cartItems[index];
                  final product = item['product']; // ✅ FIX

                  final image = (product['image'] != null &&
                          product['image'].isNotEmpty)
                      ? product['image'][0]['url']
                      : '';

                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: ListTile(
                      leading: image != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(image,
                                  width: 60, fit: BoxFit.cover),
                            )
                          : Icon(Icons.image),

                      title: Text(product['name'],
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${product['price']} VND",
                              style: TextStyle(color: Colors.red)),
                          Text("SL: ${item['quantity']}"),
                        ],
                      ),

                      trailing: IconButton(
                        icon:
                            Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          cart.removeFromCart(item['item_id']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔥 CHECKOUT
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CheckoutScreen(cartItems: cart.cartItems),
                    ),
                  );
                },
                child: Text("Thanh toán",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        );
      }),
    );
  }
}