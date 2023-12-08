import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class Voucher {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double nominal;

  Voucher({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.nominal,
  });
}

class VoucherPage extends StatefulWidget {
  const VoucherPage({Key? key}) : super(key: key);

  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final List<Voucher> vouchers = [];
  bool isAscending = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nominalController = TextEditingController();
  String selectedCategory = 'product_flat';
  final categories = [
    'product_flat',
    'order_flat',
    'free_shipping_flat',
  ];

  @override
  void initState() {
    super.initState();
    fetchVoucherData();
  }

  Future<void> fetchVoucherData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final voucherCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vouchers');

      final voucherDocs = await voucherCollection.get();

      final fetchedVouchers = voucherDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Voucher(
          id: doc.id,
          name: data['name'],
          category: data['category'],
          quantity: data['quantity'],
          nominal: data['nominal'].toDouble(),
        );
      }).toList();

      setState(() {
        vouchers.clear();
        vouchers.addAll(fetchedVouchers);
      });
    }
  }

  void _showAddVoucherDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Voucher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nominalController,
                decoration: InputDecoration(
                  labelText: 'Nominal',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      quantityController.clear();
                      nominalController.clear();
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          quantityController.text.isEmpty ||
                          nominalController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Isi Semua'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _addVoucherToFirestore();
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

  void _addVoucherToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final voucherCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vouchers');

      final newVoucher = Voucher(
        id: DateTime.now().toString(),
        name: nameController.text,
        category: selectedCategory,
        quantity: int.parse(quantityController.text),
        nominal: double.parse(nominalController.text),
      );

      // Check if the category is 'product_percentage' or 'order_percentage'
      if ((selectedCategory == 'product_percentage' ||
              selectedCategory == 'order_percentage') &&
          newVoucher.nominal > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal cannot exceed 100% for percentage categories.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await voucherCollection.add({
          'name': newVoucher.name,
          'category': newVoucher.category,
          'quantity': newVoucher.quantity,
          'nominal': newVoucher.nominal,
        });

        setState(() {
          vouchers.add(newVoucher);
        });

        Navigator.of(context).pop();
        nameController.clear();
        quantityController.clear();
        nominalController.clear();
      }
    }
  }

  void _showEditVoucherDialog(Voucher voucher, int index) {
    nameController.text = voucher.name;
    selectedCategory = voucher.category;
    quantityController.text = voucher.quantity.toString();
    nominalController.text = voucher.nominal.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Voucher'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nominalController,
                decoration: InputDecoration(
                  labelText: 'Nominal',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.clear();
                      quantityController.clear();
                      nominalController.clear();
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          quantityController.text.isEmpty ||
                          nominalController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Isi Semua'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _updateVoucherInFirestore(voucher, index);
                      }
                    },
                    child: const Text('Perbarui'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateVoucherInFirestore(Voucher voucher, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final voucherCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vouchers');

      final updatedVoucher = Voucher(
        id: voucher.id,
        name: nameController.text,
        category: selectedCategory,
        quantity: int.parse(quantityController.text),
        nominal: double.parse(nominalController.text),
      );

      // Check if the category is 'product_percentage' or 'order_percentage'
      if ((selectedCategory == 'product_percentage' ||
              selectedCategory == 'order_percentage') &&
          updatedVoucher.nominal > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal cannot exceed 100% for percentage categories.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await voucherCollection.doc(voucher.id).update({
          'name': updatedVoucher.name,
          'category': updatedVoucher.category,
          'quantity': updatedVoucher.quantity,
          'nominal': updatedVoucher.nominal,
        });

        setState(() {
          vouchers[index] = updatedVoucher;
        });

        Navigator.of(context).pop();
        nameController.clear();
        quantityController.clear();
        nominalController.clear();
      }
    }
  }

  void _showDeleteVoucherDialog(Voucher voucher, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Voucher'),
          content: const Text('Apakah Anda yakin ingin menghapus voucher ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteVoucherFromFirestore(voucher, index);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _deleteVoucherFromFirestore(Voucher voucher, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final voucherCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('vouchers');

      await voucherCollection.doc(voucher.id).delete();

      setState(() {
        vouchers.removeAt(index);
      });

      Navigator.of(context).pop();
    }
  }

  void _sortVouchers() {
    setState(() {
      isAscending = !isAscending;
      vouchers.sort((a, b) => isAscending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Vouchers',
          style: TextStyle(
            fontSize: 12, // Adjust the font size here
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.green],
        ),
        actions: [
          IconButton(
            onPressed: _sortVouchers,
            icon: Icon(
              isAscending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(voucher.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori: ${voucher.category}'),
                  Text('Jumlah: ${voucher.quantity}'),
                  Text(
                    'Nominal: ${voucher.category.contains('percentage') ? '${voucher.nominal.toStringAsFixed(2)}%' : 'Rp ${voucher.nominal.toStringAsFixed(2)}'}',
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditVoucherDialog(voucher, index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteVoucherDialog(voucher, index);
                    },
                  ),
                ],
              ),
              onTap: () {
                _showEditVoucherDialog(voucher, index);
              },
              onLongPress: () {
                _showDeleteVoucherDialog(voucher, index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVoucherDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
