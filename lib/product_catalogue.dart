import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class ProductCataloguePage extends StatefulWidget {
  const ProductCataloguePage({Key? key}) : super(key: key);

  @override
  _ProductCataloguePageState createState() => _ProductCataloguePageState();
}

class _ProductCataloguePageState extends State<ProductCataloguePage> {
  final List<Product> products = [];
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .get();

      setState(() {
        products.clear();
        products.addAll(productsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Product(
            id: doc.id,
            name: data['name'],
            price: data['price'],
            imageUrl: data['imageUrl'],
          );
        }));
      });
    }
  }

  void _updateProduct(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .doc(product.id)
            .update({
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
        });
      } catch (e) {
        // Handle error gracefully
      }
    }
  }

  void _deleteProduct(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .doc(product.id)
            .delete();
      } catch (e) {
        // Handle error gracefully
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Katalog Produk',
          style: TextStyle(
            fontSize: 12, // Adjust the font size here
          ),
        ),
        actions: [
          IconButton(
            icon: isGridView ? Icon(Icons.list) : Icon(Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.green],
        ),
      ),
      body: isGridView ? _buildGridView() : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          ).then((newProduct) {
            if (newProduct != null) {
              setState(() {
                products.add(newProduct);
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView() {
    final numberFormat = NumberFormat.currency(
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: Image.network(product.imageUrl),
          title: Text(product.name),
          subtitle: Text(numberFormat.format(product.price)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProductPage(product: product),
                    ),
                  ).then((updatedProduct) {
                    if (updatedProduct != null) {
                      _updateProduct(updatedProduct);
                      setState(() {
                        products[index] = updatedProduct;
                      });
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(product, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    final numberFormat = NumberFormat.currency(
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                numberFormat.format(product.price),
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProductPage(product: product),
                        ),
                      ).then((updatedProduct) {
                        if (updatedProduct != null) {
                          _updateProduct(updatedProduct);
                          setState(() {
                            products[index] = updatedProduct;
                          });
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(product, index);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(Product product, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Produk'),
          content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(product);
                setState(() {
                  products.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndAddProduct() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();

    if (name.isNotEmpty && price.isNotEmpty && _image != null) {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('product_images/${DateTime.now()}.png');
      final UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() async {
        final imageUrl = await storageReference.getDownloadURL();

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final product = Product(
            id: DateTime.now().toString(),
            name: name,
            price: double.parse(price),
            imageUrl: imageUrl,
          );

          await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('products').add({
            'name': product.name,
            'price': product.price,
            'imageUrl': product.imageUrl,
          });

          Navigator.pop(context, product);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan masukkan nama dan harga, lalu pilih gambar.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Tambah Produk',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pilih Gambar'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Harga (Rp)'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _uploadImageAndAddProduct,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateProductPage extends StatefulWidget {
  final Product product;

  const UpdateProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProductAndImage() async {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();

    if (name.isNotEmpty && price.isNotEmpty) {
      String updatedImageUrl = widget.product.imageUrl;

      if (_image != null) {
        final Reference storageReference =
            FirebaseStorage.instance.ref().child('product_images/${DateTime.now()}.png');
        final UploadTask uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() async {
          updatedImageUrl = await storageReference.getDownloadURL();
        });
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updatedProduct = Product(
          id: widget.product.id,
          name: name,
          price: double.parse(price),
          imageUrl: updatedImageUrl,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .doc(widget.product.id)
            .update({
          'name': updatedProduct.name,
          'price': updatedProduct.price,
          'imageUrl': updatedProduct.imageUrl,
        });

        Navigator.pop(context, updatedProduct);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan masukkan nama dan harga.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Perbarui Produk',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pilih Gambar'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Harga (Rp)'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateProductAndImage,
              child: Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductCataloguePage(),
  ));
}
