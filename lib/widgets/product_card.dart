import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map product;
  final VoidCallback onTap;

  const ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = product['Image'] != null && product['Image'].isNotEmpty
        ? product['Image'][0]['url']
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: image != ''
                  ? Image.network(
                      image,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 130,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 50),
                    ),
            ),

            // INFO
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "${product['price']} VND",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}