import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  // ❗ FIX: chỉ tạo 1 lần duy nhất
  final cart = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    // ✅ load lại mỗi khi mở màn
    cart.getCartItems();

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
                  final product = item['product'];

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
                          ? Image.network(image, width: 60)
                          : Icon(Icons.image),

                      title: Text(product['name']),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${product['price']} VND",
                              style: TextStyle(color: Colors.red)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  cart.updateQuantity(item['item_id'], item['quantity'] - 1);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text("${item['quantity']}",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              InkWell(
                                onTap: () {
                                  cart.updateQuantity(item['item_id'], item['quantity'] + 1);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(Icons.add, size: 16),
                                ),
                              ),
                            ],
                          ),
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

            Padding(
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  Get.to(() => CheckoutScreen(cartItems: cart.cartItems.toList()));
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