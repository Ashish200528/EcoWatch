import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadPage extends StatefulWidget {
  // This line was missing or incorrect. It is required to receive the uid.
  final String uid;
  const UploadPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  final _picker = ImagePicker();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to pick image: $e";
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to get location: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_imageFile == null ||
        _descriptionController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _currentPosition == null) {
      setState(() {
        _errorMessage = "Please fill all fields and select an image.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final uri = Uri.parse(
        'https://ecowatch-backend-st3b.onrender.com/upload',
      );
      final request = http.MultipartRequest('POST', uri);

      // Add all required form fields, including the uid
      request.fields['uid'] = widget.uid; // Use the uid from the widget
      request.fields['description'] = _descriptionController.text;
      request.fields['category'] = _categoryController.text;
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = "Report submitted successfully!";
          _imageFile = null;
          _descriptionController.clear();
          _categoryController.clear();
          _currentPosition = null;
        });
      } else {
        setState(() {
          _errorMessage =
              "Upload failed: ${response.statusCode} - $responseBody";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('New EcoWatch Report'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image display
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[700]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Text(
                        'No image selected',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Camera/Gallery buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            // Form fields
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (e.g., monitoring, threat)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            // Location
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _currentPosition == null
                        ? 'Location: Not set'
                        : 'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _getLocation,
                    child: const Text('Get Current Location'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                ),
                child: const Text(
                  'Submit Report',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            // Error/Success messages
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _successMessage!,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
