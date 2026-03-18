import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/product_controller.dart';
import '../controllers/map_controller.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = ProductController();
  final mapController = Get.put(MapController());

  List products = [];
  List categories = [];

  String search = '';
  String sort = 'az';
  int? selectedCategory;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final data = await controller.getProducts();
      final cate =
          await Supabase.instance.client.from('category').select();

      if (!mounted) return;

      setState(() {
        products = data;
        categories = cate;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 FILTER + SEARCH
    List filtered = products.where((p) {
      final name = p['name'].toLowerCase();

      if (!name.contains(search)) return false;

      if (selectedCategory != null &&
          p['category_id'] != selectedCategory) return false;

      return true;
    }).toList();

    // 🔤 SORT
    if (sort == 'az') {
      filtered.sort((a, b) => a['name'].compareTo(b['name']));
    } else {
      filtered.sort((a, b) => b['name'].compareTo(a['name']));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Gundam Shop"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadProducts,
              child: ListView(
                children: [
                  buildBanner(),

                  // 🔍 SEARCH
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Tìm sản phẩm...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (v) =>
                          setState(() => search = v.toLowerCase()),
                    ),
                  ),

                  // 🧩 FILTER + SORT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DropdownButton<int>(
                        hint: Text("Category"),
                        value: selectedCategory,
                        items: categories.map<DropdownMenuItem<int>>((c) {
                          return DropdownMenuItem(
                            value: c['category_id'],
                            child: Text(c['name']),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => selectedCategory = v),
                      ),
                      DropdownButton<String>(
                        value: sort,
                        items: [
                          DropdownMenuItem(
                              value: 'az', child: Text("A-Z")),
                          DropdownMenuItem(
                              value: 'za', child: Text("Z-A")),
                        ],
                        onChanged: (v) => setState(() => sort = v!),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("🔥 Sản phẩm nổi bật",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  // 🔥 SCROLL NGANG
                  SizedBox(
                    height: 270,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        final image = (p['image'] != null &&
                                p['image'].isNotEmpty)
                            ? p['image'][0]['url']
                            : "https://via.placeholder.com/150";

                        return Container(
                          width: 160,
                          margin: EdgeInsets.all(8),
                          child: buildProductCard(p, image),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("🛒 Tất cả sản phẩm",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  // GRID
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: filtered.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (_, index) {
                      final p = filtered[index];
                      final image = (p['image'] != null &&
                              p['image'].isNotEmpty)
                          ? p['image'][0]['url']
                          : "https://via.placeholder.com/150";

                      return buildProductCard(p, image);
                    },
                  ),

                  // ===== FOOTER MỚI THÊM =====
                  buildFooter(),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ===== FOOTER =====
  Widget buildFooter() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text(
                "Gundam Shop",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Expanded(child: Obx(() {
                final address = mapController.storeLocation['address']?.toString() ??
                    'Đang tải địa chỉ shop...';
                return Text(
                  address,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                );
              })),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.green, size: 20),
              SizedBox(width: 10),
              Text(
                "Hotline: 0123 456 789",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Google Map Embed (Nút bấm mở Map)
          GestureDetector(
            onTap: () async {
              final lat = mapController.storeLocation['lat'];
              final lng = mapController.storeLocation['lng'];

              final query = (lat != null && lng != null)
                  ? '$lat,$lng'
                  : (mapController.storeLocation['address']?.toString() ??
                      'Gundam Shop Ho Chi Minh');

              final Uri mapUrl = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
              );

              if (!await launchUrl(mapUrl, mode: LaunchMode.externalApplication)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể mở bản đồ'))
                );
              }
            },
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage("https://developers.google.com/static/maps/images/landing/hero_maps_static_api.png"),
                  fit: BoxFit.cover,
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black.withOpacity(0.4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, color: Colors.white, size: 40),
                      SizedBox(height: 8),
                      Text("Bấm để xem trên Google Map", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(image, fit: BoxFit.cover),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 14, color: Colors.orange),
                        Text("4.5",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),

                    SizedBox(height: 4),

                    Text("${product['price']} VND",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}