import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart'; // Import the package

class ReviewItem {
  final String id;
  final String customerName;
  final String orderId;
  final double totalPrice;
  int starRating;

  ReviewItem({
    required this.id,
    required this.customerName,
    required this.orderId,
    required this.totalPrice,
    required this.starRating,
  });
}

class ReviewPage extends StatefulWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final List<ReviewItem> reviewItems = [];

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
        return ReviewItem(
          id: doc.id,
          customerName: data['customerName'],
          orderId: doc.id,
          totalPrice: data['totalPrice'].toDouble(),
          starRating: data['starRating'] ?? 5,
        );
      }).toList();

      setState(() {
        reviewItems.clear();
        reviewItems.addAll(fetchedOrders);
      });
    }
  }

  Future<void> updateReview(ReviewItem reviewItem, int newRating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final orderCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('orders');

      await orderCollection.doc(reviewItem.orderId).update({
        'starRating': newRating,
      });

      setState(() {
        reviewItem.starRating = newRating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Ulasan Pesanan',
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
        itemCount: reviewItems.length,
        itemBuilder: (context, index) {
          final order = reviewItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('Nama Pelanggan: ${order.customerName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID Pesanan: ${order.orderId}'),
                  Text('Total Bayar: Rp ${order.totalPrice.toStringAsFixed(2)}'),
                  Text('Rating: ${order.starRating}/5'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: ReviewPage(),
      ),
    ),
  );
}
