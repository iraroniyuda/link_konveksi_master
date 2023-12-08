import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double totalEarnings = 0;
  int totalOrders = 0;
  String mostOrderedProduct = '';
  int mostOrderedQuantity = 0;
  int totalCustomers = 0;

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

      double earnings = 0;
      int orders = 0;
      final Map<String, int> productQuantities = {};
      final Set<String> uniqueCustomers = Set<String>();

      for (final doc in orderDocs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final totalPrice = data['totalPrice'] as double;
        final quantity = data['quantity'] as int;
        final productId = data['productId'] as String;
        final customerId = data['customerId'] as String; // Assuming customerId exists

        earnings += totalPrice;
        orders++;

        uniqueCustomers.add(customerId);

        if (productQuantities.containsKey(productId)) {
          productQuantities[productId] = (productQuantities[productId] ?? 0) + quantity;
        } else {
          productQuantities[productId] = quantity;
        }
      }

      String? mostOrderedProductId;

      productQuantities.forEach((productId, quantity) {
        if (quantity > mostOrderedQuantity) {
          mostOrderedQuantity = quantity;
          mostOrderedProductId = productId;
        }
      });

      if (mostOrderedProductId != null) {
        final productDoc =
            await FirebaseFirestore.instance.collection('users').doc(userId).collection('products').doc(mostOrderedProductId).get();
        final productName = productDoc['name'] as String;
        mostOrderedProduct = productName;
      }

      setState(() {
        totalEarnings = earnings;
        totalOrders = orders;
        totalCustomers = uniqueCustomers.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format totalEarnings with a comma as a thousand separator
    final formattedEarnings = NumberFormat("#,##0.00", "en_US").format(totalEarnings);

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Walletku',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildReportBlock(
              title: 'Saldo',
              value: '\Rp $formattedEarnings', // Use the formatted value
              color: Colors.blue,
              textColor: Colors.white,
            ),
            SizedBox(height: 20), // Add some spacing

            // Separator Comment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconWithCaption(
                  icon: Icons.add,
                  caption: 'Deposit',
                ),
                _buildIconWithCaption(
                  icon: Icons.remove,
                  caption: 'Withdraw',
                ),
                _buildIconWithCaption(
                  icon: Icons.history,
                  caption: 'Riwayat',
                ),
              ],
            ),
            // Other icons and buttons go here
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithCaption({required IconData icon, required String caption}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 48,
          color: Colors.blue,
        ),
        SizedBox(height: 8),
        Text(
          caption,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildReportBlock({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: 200,
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WalletPage(),
  ));
}
