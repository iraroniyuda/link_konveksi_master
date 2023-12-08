import 'package:flutter/material.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'profile.dart';
import 'wallet.dart';
import 'wishlist.dart';
import 'order.dart';
import 'product_catalogue.dart';
import 'customer.dart';
import 'voucher.dart';
import 'track.dart';
import 'stock.dart';
import 'review.dart';
import 'report.dart';
import 'live.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool showSecondaryGroup = false;

  void toggleGroup() {
    setState(() {
      showSecondaryGroup = !showSecondaryGroup;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> primaryIcons = [
      {'icon': const AssetImage('assets/custom_icons/icon1.png'), 'label': 'Produk'},
      {'icon': const AssetImage('assets/custom_icons/icon2.png'), 'label': 'Pesanan'},
      {'icon': const AssetImage('assets/custom_icons/icon3.png'), 'label': 'Toko'},
      {'icon': const AssetImage('assets/custom_icons/icon4.png'), 'label': 'Laporan'},
      {'icon': const AssetImage('assets/custom_icons/icon6.png'), 'label': 'Pelanggan'},
      {'icon': const AssetImage('assets/custom_icons/icon7.png'), 'label': 'Voucher'},
      {'icon': const AssetImage('assets/custom_icons/icon8.png'), 'label': 'Live Now'},
      {'icon': const AssetImage('assets/custom_icons/icon9.png'), 'label': 'Lainnya'},
    ];

    final List<Map<String, dynamic>> secondaryIcons = [
      {'icon': const AssetImage('assets/custom_icons/icon5.png'), 'label': 'Wallet'},
      {'icon': const AssetImage('assets/custom_icons/icon10.png'), 'label': 'Ulasan'},
      {'icon': const AssetImage('assets/custom_icons/icon11.png'), 'label': 'Wishlist'},
      {'icon': const AssetImage('assets/custom_icons/icon14.png'), 'label': 'Pelatihan'},
      {'icon': const AssetImage('assets/custom_icons/icon15.png'), 'label': 'Stok'},
      {'icon': const AssetImage('assets/custom_icons/icon16.png'), 'label': 'Lacak'},
      {'icon': const AssetImage('assets/custom_icons/icon17.png'), 'label': 'Asosiasi'},
      {'icon': const AssetImage('assets/custom_icons/icon18.png'), 'label': 'Kembali'},
    ];

    final List<Map<String, dynamic>> currentIcons = showSecondaryGroup ? secondaryIcons : primaryIcons;

    final List<String> productNames = [
      'Produk 1',
      'Produk 2',
      'Produk 3',
      'Produk 4',
      'Produk 5',
      'Produk 6',
      'Produk 7',
      'Produk 8',
      'Produk 9',
      // Add names for all products
    ];

    final List<String> productPrices = [
      'Rp 100,000',
      'Rp 200,000',
      'Rp 250,000',
      'Rp 120,000',
      'Rp 430,000',
      'Rp 220,000',
      'Rp 210,000',
      'Rp 200,000',
      'Rp 110,000',
      // Add prices for all products
    ];

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text(
          'TEXTILE MARKET',
          style: TextStyle(
            fontSize: 12.0, // Customize the font size as needed
          ),
        ),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.green], // Define your gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality here
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // First Carousel Banner
          FlutterCarousel(
            options: CarouselOptions(
              height: 200.0, // Set the height of the carousel
              showIndicator: true, // Show carousel indicators
              slideIndicator: const CircularSlideIndicator(),
              autoPlay: true, // Enable auto-play
              autoPlayInterval: const Duration(seconds: 7), // Set auto-play duration to 7 seconds
              viewportFraction: 1.0, // Set to 1.0 to display one banner at a time
            ),
            items: [
              const AssetImage('assets/images/banner1.png'),
              const AssetImage('assets/images/banner2.png'),
              const AssetImage('assets/images/banner3.png'),
            ].map<Widget>((AssetImage assetImage) {
              return Image(image: assetImage);
            }).toList(),
          ),
          // Grid of Clickable Icons (2 rows and 5 columns)
          SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: currentIcons.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildIconButton(
                      currentIcons[index]['icon'],
                      currentIcons[index]['label'],
                      () {
                        final label = currentIcons[index]['label'];
                        if (label == 'Lainnya' || label == 'Kembali') {
                          toggleGroup();
                        } else if (label == 'Produk') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductCataloguePage()),
                          );
                        } else if (label == 'Pelanggan') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomerPage()),
                          );
                        } else if (label == 'Voucher') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VoucherPage()),
                          );
                        } else if (label == 'Pesanan') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrderPage()),
                          );
                        } else if (label == 'Lacak') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TrackPage()),
                          );
                        } else if (label == 'Stok') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StockPage()),
                          );
                        } else if (label == 'Wishlist') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WishlistPage()),
                          );
                        } else if (label == 'Ulasan') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReviewPage()),
                          );
                        } else if (label == 'Laporan') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportPage()),
                          );
                        } else if (label == 'Live Now') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LivePage()),
                          );
                        } else if (label == 'Wallet') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WalletPage()),
                          );
                        } else if (label == 'Toko') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfilePage()),
                          );
                        } else {
                          // Handle button click for other icons here
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Second Carousel Banner
          FlutterCarousel(
            options: CarouselOptions(
              height: 200.0, // Set the height of the carousel
              showIndicator: true, // Show carousel indicators
              slideIndicator: const CircularSlideIndicator(),
              autoPlay: true, // Enable auto-play
              autoPlayInterval: const Duration(seconds: 7), // Set auto-play duration to 7 seconds
              viewportFraction: 1.0, // Set to 1.0 to display one banner at a time
            ),
            items: [
              const AssetImage('assets/images/banner4.png'),
              const AssetImage('assets/images/banner5.png'),
              const AssetImage('assets/images/banner6.png'),
            ].map<Widget>((AssetImage assetImage) {
              return Image(image: assetImage);
            }).toList(),
          ),
          Column(
            children: [
              const Text(
                'GALERI PRODUK',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                ),
                itemCount: 9,
                itemBuilder: (BuildContext context, int index) {
                  final imagePath = 'assets/dummy/product${index + 1}.jpg';
                  final productName = productNames[index];
                  final productPrice = productPrices[index];

                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        productName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        productPrice,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.red,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Pesan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget buildIconButton(ImageProvider<Object>? icon, String label, void Function() onPressed) {
    return Column(
      children: [
        IconButton(
          icon: icon != null ? Image(image: icon) : Container(),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
