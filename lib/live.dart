import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart'; // Import the GradientAppBar package

class Live {
  String id;
  final String timestamp;
  final String duration;
  int viewers;
  double moneyReceived; // New property for money received

  Live({
    required this.id,
    required this.timestamp,
    required this.duration,
    required this.viewers,
    this.moneyReceived = 0.0, // Default value is 0
  });
}

class LivePage extends StatefulWidget {
  const LivePage({Key? key}) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  bool isStreaming = false;
  final List<Live> lives = [];
  int viewers = 0;
  bool viewersStable = false;
  Timer? viewerUpdateTimer;
  Timer? chatTimer;

  DateTime? _streamStartTime;
  bool isFrontCamera = true;
  int highestViewers = 0;
  double moneyReceived = 0.0; // Money received during the live stream
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    fetchLivesRecords();

    Future.delayed(Duration(seconds: 10), () {
      chatTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (timer.tick % 5 == 0) {
          _addChatMessage();
        }
      });
    });
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final selectedCameraDescription = isFrontCamera
          ? cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front)
          : cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);

      _cameraController = CameraController(selectedCameraDescription, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _toggleCamera() async {
    isFrontCamera = !isFrontCamera;
    await _cameraController!.dispose();
    await _initializeCamera();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _initializeCamera();
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _initializeCamera();
      } else {}
    }
  }

  Future<void> fetchLivesRecords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final liveCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('lives');

      final livedocs = await liveCollection.get();

      final fetchedLives = livedocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Live(
          id: doc.id,
          timestamp: data['timestamp'],
          duration: data['duration'],
          viewers: data['viewers'],
          moneyReceived: data['moneyReceived'] ?? 0.0, // Default to 0
        );
      }).toList();

      // Fetch the highest viewer count from the Firestore collection
      final highestViewersDoc = await liveCollection.orderBy('viewers', descending: true).limit(1).get();
      if (highestViewersDoc.docs.isNotEmpty) {
        highestViewers = highestViewersDoc.docs.first.data()['viewers'];
      }

      setState(() {
        lives.clear();
        lives.addAll(fetchedLives);
      });
    }
  }

  void _resetHighestViewers() {
    setState(() {
      highestViewers = 0;
    });
  }

  Future<void> _startLiveStream() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        setState(() {
          isStreaming = true;
          _streamStartTime = DateTime.now();
          viewers = 0;
          highestViewers = 0;
          moneyReceived = 0.0; // Reset money received to 0
        });

        viewerUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
          setState(() {
            viewersStable = true;
            if (timer.tick <= 3) {
              viewers = Random().nextInt(50) + 1;
              moneyReceived += 0.0; // No money received for the first 10 seconds
            } else {
              final randomMoney = Random().nextInt(100) * 1000.0; // Random multiple of 1000
              moneyReceived += randomMoney;
            }
            if (viewers > highestViewers) {
              highestViewers = viewers;
            }
          });
        });

        await _cameraController!.startImageStream((image) {
          // Handle image stream if needed
        });
      }
    } else {
      await _requestCameraPermission();
    }
  }

  Future<void> _stopLiveStream() async {
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      await _cameraController!.stopImageStream();
    }
    setState(() {
      isStreaming = false;
      viewerUpdateTimer?.cancel();
      chatMessages.clear(); // Clear chat messages when stopping the live stream
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _streamStartTime != null) {
      final userId = user.uid;
      final liveCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('lives');

      DateTime streamEndTime = DateTime.now();
      Duration duration = streamEndTime.difference(_streamStartTime!);
      String formattedDuration =
          '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.toString().padLeft(2, '0')}';

      // Save the highest viewer count instead of the current viewer count
      await liveCollection.add({
        'duration': formattedDuration,
        'timestamp': streamEndTime.toLocal().toString().split('.')[0],
        'viewers': highestViewers,
        'moneyReceived': moneyReceived, // Save the money received
      });

      final liveId = (await liveCollection.orderBy('timestamp', descending: true).limit(1).get()).docs.first.id;
      final newLive = Live(
        id: liveId,
        timestamp: streamEndTime.toLocal().toString().split('.')[0],
        duration: formattedDuration,
        viewers: highestViewers,
        moneyReceived: moneyReceived, // Set the money received
      );

      setState(() {
        lives.insert(0, newLive);
      });
    }
  }

  Future<void> _deleteRecord(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final liveCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('lives');

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await liveCollection.doc(id).delete();
                setState(() {
                  lives.removeWhere((live) => live.id == id);
                });
              },
              child: Text('Hapus'),
            ),
          ],
        ),
      );
    }
  }

  final List<String> chatMessages = [];

  void _addChatMessage() {
    final newMessage = 'penonton${Random().nextInt(99999999)}: Contoh Pesan ${Random().nextInt(99)}';
    setState(() {
      chatMessages.add(newMessage);
    });

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    viewerUpdateTimer?.cancel();
    chatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isStreaming) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: GradientAppBar( // Use GradientAppBar here
          title: Text(
            'Live Streaming',
            style: TextStyle(
              fontSize: 12, // Customize the font size here
            ),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.green],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isStreaming)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _resetHighestViewers();
                    _startLiveStream();
                  },
                  child: Text('Mulai Live'),
                ),
              ),
            if (isStreaming)
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 800,
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'Penonton Terkini: $viewers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Penonton Tertinggi: $highestViewers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Gift Diterima: \Rp ${moneyReceived.toStringAsFixed(2)}', // Format with two decimal places and comma
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    if (!isStreaming || DateTime.now().difference(_streamStartTime!) >= Duration(seconds: 10))
                      Positioned(
                        bottom: 100,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 300,
                          color: Colors.black.withOpacity(0.0),
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: chatMessages.length,
                            itemBuilder: (ctx, index) {
                              final chatMessage = chatMessages[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                child: Text(
                                  chatMessage,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (!isStreaming)
              Expanded(
                child: ListView.builder(
                  itemCount: lives.length,
                  itemBuilder: (ctx, index) {
                    final live = lives[index];
                    return ListTile(
                      title: Text(live.timestamp),
                      subtitle: Text('Durasi ${live.duration}, Penonton Tertinggi: ${live.viewers}, Gift Diterima: \Rp ${live.moneyReceived.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteRecord(live.id),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        floatingActionButton: isStreaming
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _stopLiveStream,
                    child: Icon(Icons.stop),
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: _toggleCamera,
                    child: Icon(Icons.switch_camera),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: LivePage(),
  ));
}
