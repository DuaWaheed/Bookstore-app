import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    orderData['createdAt'] = FieldValue.serverTimestamp();
    await orders.add(orderData);
  }

  Stream<QuerySnapshot> getUserOrders(String userId) {
    return orders.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await orders.doc(orderId).update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
