import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart'; // Import the package

class TrackOrder {
  final String id;
  final String customerId;
  final String productId;
  final String voucherId;
  final int quantity;
  final String shippingAddress;
  final double totalPrice;
  final String customerName;
  final String productName;
  final String voucherName;
  String orderStatus; // New property for order status

  TrackOrder({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.voucherId,
    required this.quantity,
    required this.shippingAddress,
    required this.totalPrice,
    required this.customerName,
    required this.productName,
    required this.voucherName,
    required this.orderStatus, // Initialize order status
  });
}

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  final List<TrackOrder> trackedOrders = [];

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final orderCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('orders');

      final orderDocs = await orderCollection.get();

      final fetchedOrders = orderDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TrackOrder(
          id: doc.id,
          customerId: data['customerId'],
          productId: data['productId'],
          voucherId: data['voucherId'],
          quantity: data['quantity'],
          shippingAddress: data['shippingAddress'],
          totalPrice: data['totalPrice'].toDouble(),
          customerName: data['customerName'],
          productName: data['productName'],
          voucherName: data['voucherName'],
          orderStatus: data['orderStatus'] ?? 'baru', // Retrieve order status
        );
      }).toList();

      setState(() {
        trackedOrders.clear();
        trackedOrders.addAll(fetchedOrders);
      });
    }
  }

  Future<void> updateOrderStatus(TrackOrder order, String newStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final orderCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('orders');

      await orderCollection.doc(order.id).update({
        'orderStatus': newStatus,
      });

      setState(() {
        order.orderStatus = newStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Lacak Pesanan',
          style: TextStyle(
            fontSize: 12, // Adjust the font size here
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.green],
        ),
      ),
      body: ListView.builder(
        itemCount: trackedOrders.length,
        itemBuilder: (context, index) {
          final order = trackedOrders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('ID Pesanan: ${order.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pelanggan: ${order.customerName}'),
                  Text('Produk: ${order.productName}'),
                  Text('Voucher: ${order.voucherName}'),
                  Text('Jumlah: ${order.quantity}'),
                  Text('Alamat Pengiriman: ${order.shippingAddress}'),
                  Text('Total Bayar: Rp ${order.totalPrice}'),
                  DropdownButtonFormField<String>(
                    value: order.orderStatus,
                    onChanged: (newStatus) {
                      updateOrderStatus(order, newStatus!);
                    },
                    items: [
                      'baru',
                      'dibayar',
                      'diproses',
                      'dikirim',
                      'selesai',
                    ].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
