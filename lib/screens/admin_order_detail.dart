import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final _client = Supabase.instance.client;
  final AdminController controller = AdminController();
  List<dynamic> orderDetails = [];
  bool isLoading = true;
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order['status'] ?? 'Pending';
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final orderId = widget.order['order_id'];
      
      final data = await _client
          .from('orderdetail')
          .select('*, product(*)') // Lấy chi tiết kèm thông tin sản phẩm
          .eq('order_id', orderId);

      if (mounted) {
        setState(() {
          orderDetails = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải chi tiết đơn hàng: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    
    // Xử lý thông tin khách hàng nếu có join bảng
    String customerPhone = "";
    String customerName = "Unknown";
    
    if (order['customer_id'] is Map) {
         customerName = order['customer_id']['full_name'] ?? order['customer_id']['email'] ?? "Khách hàng";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết đơn #${order['order_id']}"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Get.defaultDialog(
                title: "Xóa đơn hàng",
                middleText: "Bạn có chắc chắn muốn xóa đơn hàng này? Hành động này không thể hoàn tác.",
                textCancel: "Hủy",
                textConfirm: "Xóa",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () async {
                  Get.back(); // Đóng dialog
                  setState(() => isLoading = true);
                  try {
                    await controller.deleteOrder(order['order_id']);
                    Get.back(result: true); // Trở về danh sách
                    Get.snackbar("Thành công", "Đã xóa đơn hàng");
                  } catch (e) {
                    setState(() => isLoading = false);
                    Get.snackbar("Lỗi", "Không thể xóa đơn hàng: $e", backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
              );
            }
          )
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.orange))
        : ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin chung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  SizedBox(height: 8),
                  
                  // Detail Row builder
                  _buildInfoRow(Icons.person, "Khách hàng:", customerName),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.calendar_today, "Ngày đặt:", order['created_at'] != null 
                    ? DateTime.parse(order['created_at']).toLocal().toString().split('.')[0] 
                    : "N/A"),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.payment, "Thanh toán:", "${order['payment_method'] ?? 'N/A'}"),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.money, "Tổng tiền:", "${order['total_amount']} VND", titleColor: Colors.red),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Text("Trạng thái: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Container(
                        height: 36,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(currentStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getStatusColor(currentStatus)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentStatus,
                            icon: Icon(Icons.arrow_drop_down, color: _getStatusColor(currentStatus)),
                            style: TextStyle(
                              color: _getStatusColor(currentStatus),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            items: ["Pending", "Processing", "Shipped", "Delivered", "Cancelled"]
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (val) async {
                              if (val != null) {
                                try {
                                  await controller.updateOrderStatus(order['order_id'], val);
                                  setState(() {
                                    currentStatus = val;
                                  });
                                  Get.snackbar("Thành công", "Đã cập nhật trạng thái");
                                } catch (e) {
                                  Get.snackbar("Lỗi", "Không thể cập nhật trạng thái: $e");
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          Text("Sản phẩm trong đơn (${orderDetails.length})", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          
          // Products list
          ...orderDetails.map((item) {
            final product = item['product'] ?? {};
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.inventory_2, color: Colors.grey),
                ),
                title: Text(product['name'] ?? 'Sản phẩm không xác định', 
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SL: ${item['quantity']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Đơn giá: ${item['unit_price']} VND", style: TextStyle(color: Colors.red)),
                  ],
                ),
                trailing: Text("${(item['quantity'] * item['unit_price'])} VND", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Color? titleColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 10),
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(width: 8),
        Expanded(child: Text(value, style: TextStyle(color: titleColor ?? Colors.black87, fontWeight: titleColor != null ? FontWeight.bold : FontWeight.normal))),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Processing': return Colors.blue;
      case 'Shipped': case 'Shipping': return Colors.cyan;
      case 'Delivered': case 'Completed': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
