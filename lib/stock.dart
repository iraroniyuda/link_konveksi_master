import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart'; // Import the package

class StockItem {
  final String id;
  final double productPrice;
  final String productName;
  int stockQuantity;

  StockItem({
    required this.id,
    required this.productPrice,
    required this.productName,
    required this.stockQuantity,
  });
}

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final List<StockItem> stockItems = [];

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
        return StockItem(
          id: doc.id,
          productName: data['name'],
          productPrice: data['price'],
          stockQuantity: (data['stockQuantity'] != null) ? int.tryParse(data['stockQuantity'].toString()) ?? 0 : 0,
        );
      }).toList();

      setState(() {
        stockItems.clear();
        stockItems.addAll(fetchedProducts);
      });
    }
  }

  Future<void> updateStockQuantity(StockItem stockItem, int newQuantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final productCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('products');


      await productCollection.doc(stockItem.id).update({
        'stockQuantity': newQuantity,
      });

      setState(() {
        stockItem.stockQuantity = newQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Stok',
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
        itemCount: stockItems.length,
        itemBuilder: (context, index) {
          final product = stockItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('Produk: ${product.productName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harga: Rp ${product.productPrice}'),
                  Text('Jumlah Stok: ${product.stockQuantity}'),
                  SizedBox(
                    width: 100, // Adjust the width as needed
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Jumlah Baru'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // Handle the new quantity input
                      if (value.isNotEmpty) {
                        final newQuantity = int.tryParse(value) ?? 0;
                        updateStockQuantity(product, newQuantity);
                      } else {
                        // Handle the case when the input is empty or not a valid integer.
                        // You can show an error message or take appropriate action.
                      }
                    },

                    ),
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
