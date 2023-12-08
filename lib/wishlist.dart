import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class WishlistItem {
  final String id;
  final double productPrice;
  final String productName;
  int wishlistNumber;

  WishlistItem({
    required this.id,
    required this.productPrice,
    required this.productName,
    required this.wishlistNumber,
  });
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final List<WishlistItem> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final productCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('products');

      final productDocs = await productCollection.get();

      final fetchedProducts = productDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return WishlistItem(
          id: doc.id,
          productName: data['name'],
          productPrice: data['price'],
          wishlistNumber: Random().nextInt(100), // Generate a random wishlist number
        );
      }).toList();

      setState(() {
        wishlistItems.clear();
        wishlistItems.addAll(fetchedProducts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Wishlist',
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
        itemCount: wishlistItems.length,
        itemBuilder: (context, index) {
          final product = wishlistItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('Produk: ${product.productName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harga: Rp ${product.productPrice}'),
                  Text('Jumlah Wishlist: ${product.wishlistNumber}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
