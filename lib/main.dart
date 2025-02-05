import 'dart:typed_data';
import 'dart:io'; // Import this for file operations
import 'dart:ui';
import 'package:path_provider/path_provider.dart'; // For directory management
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'grpc_client.dart';
import 'package:testing/service.pb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _stream;
  bool isLoading = true;
  String? errorMessage;
  final GrpcClient grpcClient = GrpcClient();
  final GlobalKey _globalKey = GlobalKey(); // Add GlobalKey here

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _localRenderer.initialize();
    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': false,
      });
      setState(() {
        _stream = stream;
        _localRenderer.srcObject = stream;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to initialize camera: $e';
        isLoading = false;
      });
    }
  }

  Future<void> captureAndSaveFrame() async {
    if (_stream == null) {
      print('No video stream found.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video stream found')),
      );
      return;
    }

    try {
      final bytes = await captureFrame();
      if (bytes != null) {
        print('Captured image bytes: ${bytes.length}');

        // Save the captured image locally
        await _saveImageLocally(bytes);

        // Optionally send to the server via gRPC
        await grpcClient.sendImage(ImageRequest()..imageData = bytes);
      } else {
        print('No bytes captured from frame.');
      }
    } catch (e) {
      print('Error capturing frame: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing frame: $e')),
      );
    }
  }

  Future<void> _saveImageLocally(Uint8List imageBytes) async {
    try {
      // Ensure the captured directory exists
      Directory directory = Directory('${Directory.current.path}/lib/captured');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String imagePath = '${directory.path}/captured_image.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      print('Image successfully saved at $imagePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved at $imagePath')),
      );
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  Future<Uint8List?> captureFrame() async {
    try {
      // Capture the current widget as an image
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      print('Error capturing frame: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera App')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localRenderer.srcObject != null
              ? RepaintBoundary( // Wrap RTCVideoView with RepaintBoundary
                  key: _globalKey,
                  child: RTCVideoView(_localRenderer),
                )
              : Center(child: Text('Camera not initialized: $errorMessage')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SchedulerBinding.instance.addPostFrameCallback((_) async {
            await captureAndSaveFrame();
          });
        },
        child: const Icon(Icons.camera),
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _stream?.getTracks().forEach((track) {
      track.stop();
    });
    grpcClient.shutdown();
    super.dispose();
  }
}
