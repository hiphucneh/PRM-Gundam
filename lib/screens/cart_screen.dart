import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final cart = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giỏ hàng")),
      body: Obx(() {
        if (cart.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (cart.cartItems.isEmpty) {
          return Center(child: Text("Giỏ hàng trống"));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cart.cartItems[index];

                  return Card(
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(item['Product']['name']),
                      subtitle: Text("Số lượng: ${item['quantity']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          cart.removeFromCart(item['item_id']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // CHECKOUT BUTTON
            Padding(
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        cartItems: cart.cartItems,
                      ),
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