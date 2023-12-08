import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart'; // Import GradientAppBar

class Order {
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

  Order({
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
  });
}

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<Order> orders = [];
  bool isAscending = true;
  TextEditingController quantityController = TextEditingController();
  TextEditingController shippingAddressController = TextEditingController();
  String? selectedCustomer;
  String? selectedProduct;
  String? selectedVoucher;

  List<DropdownMenuItem<String>> customerDropdownItems = [];
  List<DropdownMenuItem<String>> productDropdownItems = [];
  List<DropdownMenuItem<String>> voucherDropdownItems = [];

  @override
  void initState() {
    super.initState();
    fetchOrderData();
    fetchDropdownData();
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
        return Order(
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
        );
      }).toList();

      setState(() {
        orders.clear();
        orders.addAll(fetchedOrders);
      });
    }
  }

  Future<void> fetchDropdownData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final customerCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('customers');

      final customerDocs = await customerCollection.get();

      customerDropdownItems = customerDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem(
          value: doc.id,
          child: Text(data['name']),
        );
      }).toList();

      final productCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('products');

      final productDocs = await productCollection.get();

      productDropdownItems = productDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem(
          value: doc.id,
          child: Text(data['name']),
        );
      }).toList();

      final voucherCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('vouchers');

      final voucherDocs = await voucherCollection.get();

      voucherDropdownItems = [
        DropdownMenuItem(
          value: 'no_voucher',
          child: Text('Tanpa Voucher'),
        ),
        ...voucherDocs.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DropdownMenuItem(
            value: doc.id,
            child: Text(data['name']),
          );
        }),
      ];
    }
  }

  double calculateTotalPrice(double productPrice, double voucherNominal, int quantity) {
    return (productPrice * quantity) - voucherNominal;
  }

  void _showAddOrderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCustomer,
                onChanged: (value) {
                  setState(() {
                    selectedCustomer = value;
                  });
                },
                items: customerDropdownItems,
                decoration: const InputDecoration(labelText: 'Pelanggan'),
              ),
              DropdownButtonFormField<String>(
                value: selectedProduct,
                onChanged: (value) {
                  setState(() {
                    selectedProduct = value;
                  });
                },
                items: productDropdownItems,
                decoration: const InputDecoration(labelText: 'Produk'),
              ),
              DropdownButtonFormField<String>(
                value: selectedVoucher,
                onChanged: (value) {
                  setState(() {
                    selectedVoucher = value;
                  });
                },
                items: voucherDropdownItems,
                decoration: const InputDecoration(labelText: 'Voucher'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: shippingAddressController,
                decoration: const InputDecoration(labelText: 'Alamat Kirim'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _resetFormFields(); // Reset form fields
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedCustomer == null ||
                          selectedProduct == null ||
                          quantityController.text.isEmpty ||
                          shippingAddressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Isi semuanya dahulu.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _addOrderToFirestore();
                      }
                    },
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetFormFields() {
    setState(() {
      selectedCustomer = null;
      selectedProduct = null;
      selectedVoucher = null;
    });

    quantityController.clear();
    shippingAddressController.clear();
  }

  Future<void> _addOrderToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final orderCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('orders');

      final customerData = await fetchCustomerData(selectedCustomer!);
      final productData = await fetchProductData(selectedProduct!);

      double voucherNominal = 0;
      String voucherName = 'No Voucher';
      if (selectedVoucher != 'no_voucher') {
        final voucherData = await fetchVoucherData(selectedVoucher!);
        if (voucherData['nominal'] is double) {
          voucherNominal = voucherData['nominal'] as double;
        }
        voucherName = voucherData['name'] ?? 'No Voucher';
      }

      final productPrice = productData['price'] as double;

      final orderTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final newOrder = Order(
        id: orderTimestamp,
        customerId: selectedCustomer!,
        productId: selectedProduct!,
        voucherId: selectedVoucher!,
        quantity: int.parse(quantityController.text),
        shippingAddress: shippingAddressController.text,
        totalPrice: calculateTotalPrice(productPrice, voucherNominal, int.parse(quantityController.text)),
        customerName: customerData['name'] ?? 'Customer Not Found',
        productName: productData['name'] ?? 'Product Not Found',
        voucherName: voucherName,
      );

      final totalPrice = calculateTotalPrice(productPrice, voucherNominal, int.parse(quantityController.text));

      if (totalPrice < 0) {
        await orderCollection.doc(orderTimestamp).set({
          'customerId': newOrder.customerId,
          'productId': newOrder.productId,
          'voucherId': newOrder.voucherId,
          'quantity': newOrder.quantity,
          'shippingAddress': newOrder.shippingAddress,
          'totalPrice': 0,
          'customerName': newOrder.customerName,
          'productName': newOrder.productName,
          'voucherName': newOrder.voucherName,
        });
      } else {
        await orderCollection.doc(orderTimestamp).set({
          'customerId': newOrder.customerId,
          'productId': newOrder.productId,
          'voucherId': newOrder.voucherId,
          'quantity': newOrder.quantity,
          'shippingAddress': newOrder.shippingAddress,
          'totalPrice': totalPrice,
          'customerName': newOrder.customerName,
          'productName': newOrder.productName,
          'voucherName': newOrder.voucherName,
        });
      }

      _resetFormFields(); // Reset form fields

      await fetchOrderData();

      Navigator.of(context).pop();
    }
  }

  void _sortOrders() {
    setState(() {
      isAscending = !isAscending;
      orders.sort((a, b) => isAscending ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
    });
  }

  void _showDeleteOrderDialog(Order order, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pesanan'),
          content: const Text('Apakah Anda yakin ingin menghapus pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteOrderFromFirestore(order, index);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _deleteOrderFromFirestore(Order order, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final orderCollection =
          FirebaseFirestore.instance.collection('users').doc(userId).collection('orders');

      await orderCollection.doc(order.id).delete();

      setState(() {
        orders.removeAt(index);
      });

      Navigator.of(context).pop();
    }
  }

  Future<Map<String, dynamic>> fetchCustomerData(String customerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final customerData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customers')
          .doc(customerId)
          .get();

      if (customerData.exists) {
        return customerData.data() as Map<String, dynamic>;
      }
    }
    return {}; // Return an empty map if data not found
  }

  Future<Map<String, dynamic>> fetchProductData(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final productData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('products')
          .doc(productId)
          .get();

      if (productData.exists) {
        return productData.data() as Map<String, dynamic>;
      }
    }
    return {}; // Return an empty map if data not found
  }

  Future<Map<String, dynamic>> fetchVoucherData(String voucherId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final voucherData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vouchers')
          .doc(voucherId)
          .get();

      if (voucherData.exists) {
        return voucherData.data() as Map<String, dynamic>;
      }
    }
    return {}; // Return an empty map if data not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar( // Use GradientAppBar here
        title: const Text(
          'Pesanan',
          style: TextStyle(fontSize: 12), // Adjust the font size here
        ),
        actions: [
          IconButton(
            onPressed: _sortOrders,
            icon: Icon(
              isAscending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.green],
        ),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
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
                  Text('Harga Total: Rp ${order.totalPrice}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteOrderDialog(order, index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderPage(),
  ));
}
