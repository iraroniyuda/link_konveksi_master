import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class Customer {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final List<Customer> customers = [];
  bool isAscending = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final customerCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customers');

      final customerDocs = await customerCollection.get();

      final fetchedCustomers = customerDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Customer(
          id: doc.id,
          name: data['name'],
          address: data['address'],
          phoneNumber: data['phoneNumber'],
        );
      }).toList();

      setState(() {
        customers.clear();
        customers.addAll(fetchedCustomers);
      });
    }
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(labelText: 'No HP'),
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
                      addressController.clear();
                      phoneNumberController.clear();
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          phoneNumberController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Isi semuanya dahulu.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _addCustomerToFirestore();
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

  void _addCustomerToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final customerCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customers');

      final newCustomer = Customer(
        id: DateTime.now().toString(),
        name: nameController.text,
        address: addressController.text,
        phoneNumber: phoneNumberController.text,
      );

      await customerCollection.add({
        'name': newCustomer.name,
        'address': newCustomer.address,
        'phoneNumber': newCustomer.phoneNumber,
      });

      setState(() {
        customers.add(newCustomer);
      });

      Navigator.of(context).pop();
      nameController.clear();
      addressController.clear();
      phoneNumberController.clear();
    }
  }

  void _showEditCustomerDialog(Customer customer, int index) {
    nameController.text = customer.name;
    addressController.text = customer.address;
    phoneNumberController.text = customer.phoneNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(labelText: 'No HP'),
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
                      addressController.clear();
                      phoneNumberController.clear();
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          phoneNumberController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Isi semuanya dahulu.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _updateCustomerInFirestore(customer, index);
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

  void _updateCustomerInFirestore(Customer customer, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final customerCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customers');

      final updatedCustomer = Customer(
        id: customer.id,
        name: nameController.text,
        address: addressController.text,
        phoneNumber: phoneNumberController.text,
      );

      await customerCollection.doc(customer.id).update({
        'name': updatedCustomer.name,
        'address': updatedCustomer.address,
        'phoneNumber': updatedCustomer.phoneNumber,
      });

      setState(() {
        customers[index] = updatedCustomer;
      });

      Navigator.of(context).pop();
      nameController.clear();
      addressController.clear();
      phoneNumberController.clear();
    }
  }

  void _showDeleteCustomerDialog(Customer customer, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pelanggan'),
          content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteCustomerFromFirestore(customer, index);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCustomerFromFirestore(Customer customer, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final customerCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('customers');

      await customerCollection.doc(customer.id).delete();

      setState(() {
        customers.removeAt(index);
      });

      Navigator.of(context).pop();
    }
  }

  void _sortCustomers() {
    setState(() {
      isAscending = !isAscending;
      customers.sort((a, b) => isAscending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar( // Use GradientAppBar from the package
        title: const Text(
          'Pelanggan',
          style: TextStyle(fontSize: 12.0), // Adjust the font size as needed
        ),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        actions: [
          IconButton(
            onPressed: _sortCustomers,
            icon: Icon(
              isAscending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(customer.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.address),
                  Text(customer.phoneNumber),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditCustomerDialog(customer, index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteCustomerDialog(customer, index);
                    },
                  ),
                ],
              ),
              onTap: () {
                _showEditCustomerDialog(customer, index);
              },
              onLongPress: () {
                _showDeleteCustomerDialog(customer, index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
