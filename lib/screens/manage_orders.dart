import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryPurple = Color(0xFF8E24AA);
const Color kLighterPurple = Color(0xFFF3E5F5);

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final ordersRef = FirebaseFirestore.instance.collection('orders');
  final usersRef = FirebaseFirestore.instance.collection('users');

  // --- UPDATE ORDER STATUS ---
  Future<void> _updateOrderStatus(String orderId, String currentStatus) async {
    final statuses = ['Pending', 'Shipped', 'Delivered', 'Cancelled'];
    String selected = currentStatus;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Order Status',
            style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryPurple)),
        content: DropdownButtonFormField<String>(
          value: selected,
          items: statuses
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => selected = v!,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryPurple),
            onPressed: () async {
              await ordersRef.doc(orderId).update({
                'status': selected,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Status updated to $selected")),
              );
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DELETE CONFIRM ---
  Future<void> _confirmDelete(String orderId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Order", style: TextStyle(color: Colors.red)),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ordersRef.doc(orderId).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Order deleted"), backgroundColor: Colors.red));
    }
  }
// --- SHOW ORDER ITEMS ---
void _showOrderItems(List items) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Order Items",
        style: TextStyle(
          color: kPrimaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: items.isEmpty
            ? const Text("No items found in this order.")
            : ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    leading: const Icon(Icons.book, color: kPrimaryPurple),
                    title: Text(item['title'] ?? 'Unknown Book'),
                    subtitle: Text(
                      'Qty: ${item['quantity']} | Rs. ${item['price']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(color: kPrimaryPurple, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

  // --- FORMAT DATE ---
  String _formatDate(dynamic ts) {
    try {
      if (ts == null) return "N/A";
      final d = ts is Timestamp ? ts.toDate() : DateTime.tryParse(ts.toString());
      return d == null
          ? "N/A"
          : "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "N/A";
    }
  }

  // --- FETCH USER INFO USING userId ---
  Future<Map<String, dynamic>> _fetchUserInfo(String userId) async {
    try {
      final userDoc = await usersRef.doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLighterPurple,
      appBar: AppBar(
        backgroundColor: kPrimaryPurple,
        title: const Text("Orders Management", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryPurple));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final data = orders[i].data() as Map<String, dynamic>? ?? {};
              final orderId = orders[i].id;
              final userId = data['userId'] ?? '';
              final total = data['totalPrice'] ?? 0;
              final status = data['status'] ?? 'Pending';
              final createdAt = _formatDate(data['createdAt']);
              final updatedAt = _formatDate(data['updatedAt']);
              final items = data['items'] ?? [];

              Color statusColor = Colors.grey;
              if (status == 'Delivered') statusColor = Colors.green;
              else if (status == 'Shipped') statusColor = Colors.orange;
              else if (status == 'Cancelled') statusColor = Colors.red;

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchUserInfo(userId),
                builder: (context, userSnap) {
                  final userData = userSnap.data ?? {};
                  final email = userData['email'] ?? 'Unknown';
                  final address = userData['address'] ?? 'Not provided';
                  final payment = userData['payment'] ?? 'Not provided';
                  final name = userData['name'] ?? 'User';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("Email: $email"),
                          const Divider(color: kPrimaryPurple, thickness: 1),
                          Text("Shipping Address: $address"),
                          Text("Payment Method: $payment"),
                          Text("Total Price: Rs. $total"),
                          Text("Created: $createdAt"),
                          Text("Updated: $updatedAt"),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                              Chip(
                                label: Text(status, style: const TextStyle(color: Colors.white)),
                                backgroundColor: statusColor,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.receipt_long, color: kPrimaryPurple),
                                label: const Text("View Items", style: TextStyle(color: kPrimaryPurple)),
                                onPressed: () => _showOrderItems(items),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => _updateOrderStatus(orderId, status),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(orderId),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
