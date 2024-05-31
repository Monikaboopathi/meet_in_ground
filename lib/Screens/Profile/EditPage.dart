import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';


class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();
  String? _location;
  String? _selectedImage;
  List<String> _selectedSports = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> sportNames = [
    {'id': 1, 'name': 'Football'},
    {'id': 2, 'name': 'Basketball'},
  ];

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile.path;
      });
    }
  }

  Future<void> fetchLocationInfo(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _location = data['display_name'] ?? 'Unknown location';
        });
      }
    } catch (error) {
      print('Error fetching location: $error');
    }
  }

  Future<void> handleLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    fetchLocationInfo(_locationData.latitude!, _locationData.longitude!);
  }

  Future<void> handleSave() async {
    if (_usernameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your username.');
      return;
    }
    if (_location == null || _location!.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please select your location.');
      return;
    }
    if (_selectedSports.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select at least one sport.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mock the API call for updating profile
      await Future.delayed(Duration(seconds: 2));

      Fluttertoast.showToast(msg: 'Profile updated successfully');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Failed to update profile');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: ThemeService.background,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.textColor, size: 35),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 4),
            ),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: ThemeService.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: _selectedImage != null
                    ? Image.file(
                        File(_selectedImage!),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://via.placeholder.com/200',
                        height: 200,
                        width: 200,
                      ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: handleLocation,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _location ?? 'Select your location',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Icon(Icons.location_on, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => setState(() {
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedSports.isEmpty
                              ? 'Select your sports'
                              : _selectedSports.join(', '),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Icon(Icons.sports, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : handleSave,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save'),
              ),
            ],
          ),
        ),
         );
  }
}
