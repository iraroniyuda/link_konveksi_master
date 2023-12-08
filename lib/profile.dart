import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class UserProfile {
  final String id;
  final String ownerName;
  final String address;
  final String phoneNumber;
  final String profileImageUrl;

  UserProfile({
    required this.id,
    required this.ownerName,
    required this.address,
    required this.phoneNumber,
    required this.profileImageUrl,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _profileImage;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('profile_data')
          .get();

      if (userProfileSnapshot.exists) {
        final data = userProfileSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _userProfile = UserProfile(
            id: user.uid,
            ownerName: data['ownerName'],
            address: data['address'],
            phoneNumber: data['phoneNumber'],
            profileImageUrl: data['profileImageUrl'],
          );

          _ownerNameController.text = _userProfile!.ownerName;
          _addressController.text = _userProfile!.address;
          _phoneNumberController.text = _userProfile!.phoneNumber;
        });
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfileImageAndSave() async {
    final ownerName = _ownerNameController.text.trim();
    final address = _addressController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    if (ownerName.isNotEmpty && address.isNotEmpty && phoneNumber.isNotEmpty) {
      String updatedProfileImageUrl = _userProfile?.profileImageUrl ?? '';

      if (_profileImage != null) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_picture/${DateTime.now()}.png');
        final UploadTask uploadTask = storageReference.putFile(_profileImage!);
        await uploadTask.whenComplete(() async {
          updatedProfileImageUrl = await storageReference.getDownloadURL();
        });
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userProfile = UserProfile(
          id: user.uid,
          ownerName: ownerName,
          address: address,
          phoneNumber: phoneNumber,
          profileImageUrl: updatedProfileImageUrl,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('profile_data')
            .set({
          'ownerName': userProfile.ownerName,
          'address': userProfile.address,
          'phoneNumber': userProfile.phoneNumber,
          'profileImageUrl': userProfile.profileImageUrl,
        });

        setState(() {
          _userProfile = userProfile;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan isi semua kolom dan pilih gambar profil.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          'Edit Profil Toko',
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
              onPressed: _pickProfileImage,
              child: const Text('Pilih Foto Profil'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _ownerNameController,
              decoration: const InputDecoration(labelText: 'Nama Pemilik'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No HP'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _uploadProfileImageAndSave,
              child: const Text('Simpan Profil'),
            ),
            const SizedBox(height: 16.0),
            _userProfile != null
                ? Column(
                    children: [
                      Text(
                        'Foto Profil Terpasang:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 0),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Transform.scale(
                          scale: 0.25,
                          child: Image.network(_userProfile!.profileImageUrl),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ProfilePage(),
  ));
}
