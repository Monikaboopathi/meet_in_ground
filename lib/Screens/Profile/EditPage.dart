import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  EditProfile({required this.userDetails});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _locationController = TextEditingController();
  String? _selectedImage;
  List<String> _selectedSports = [];
  bool _isLocationLoading = false;

  List<Map<String, dynamic>> sportNames = [
    {'id': 1, 'name': 'Football'},
    {'id': 2, 'name': 'Basketball'},
    {'id': 3, 'name': 'Tennis'},
    {'id': 4, 'name': 'Cricket'},
    {'id': 5, 'name': 'Rugby'},
    {'id': 6, 'name': 'Soccer'},
    {'id': 7, 'name': 'Golf'},
    {'id': 8, 'name': 'Swimming'},
    {'id': 9, 'name': 'Baseball'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values from userDetails
    _usernameController =
        TextEditingController(text: widget.userDetails['userName']);
    _locationController =
        TextEditingController(text: widget.userDetails['location']);
    _selectedImage = widget.userDetails['profileImg'];
    _selectedSports = widget.userDetails['sport']?.split(',') ?? [];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile.path;
      });
    }
  }

  Future<void> handleLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    Location location = Location();
    LocationData? locationData;

    try {
      locationData = await location.getLocation();
      _locationController.text =
          'Lat: ${locationData.latitude}, Long: ${locationData.longitude}';
    } catch (error) {
      print('Error getting location: $error');
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> handleSave() async {
    if (_usernameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your username.');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please select your location.');
      return;
    }
    if (_selectedSports.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select at least one sport.');
      return;
    }

    setState(() {});
    String? userMobileNumber = await MobileNo.getMobilenumber();
    print(userMobileNumber);

    try {
      String url =
          'https://bet-x-new.onrender.com/user/updateUser/$userMobileNumber';
      String username = _usernameController.text.trim();
      String sports = _selectedSports.join(',');
      String location = _locationController.text.trim();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      Map<String, dynamic> body = {
        'userName': username,
        'sport': sports,
        'location': location,
      };
      print(username);
      print(sports);
      print(location);
      if (_selectedImage != null) {
        body['profileImg'] =
            base64Encode(File(_selectedImage!).readAsBytesSync());
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to update profile",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      print(error);
    } finally {
      setState(() {});
    }
  }

  Future<void> showSportsDialog() async {
    List<String> tempSelectedSports = List.from(_selectedSports);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Sports'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: sportNames.map((sport) {
                    return CheckboxListTile(
                      value: tempSelectedSports.contains(sport['name']),
                      title: Text(sport['name']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedSports.add(sport['name']);
                          } else {
                            tempSelectedSports.remove(sport['name']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Save'),
                      onPressed: () {
                        setState(() {
                          _selectedSports = tempSelectedSports;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: _selectedImage != null
                      ? FileImage(File(_selectedImage!))
                      : null,
                  child: _selectedImage == null
                      ? Icon(Icons.person, size: 80, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: ThemeService.buttonBg,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: handleLocation,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _isLocationLoading
                                ? Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: ThemeService.buttonBg,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Fetching location...',
                                        softWrap: true,
                                      ),
                                    ],
                                  )
                                : TextField(
                                    controller: _locationController,
                                    decoration: InputDecoration(
                                      hintText: 'Select your location',
                                      border: InputBorder.none,
                                    ),
                                  ),
                          ),
                          Icon(Icons.location_on, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text(
                        'Sports',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: showSportsDialog,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
                  SizedBox(height: 36.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleSave,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: ThemeService.buttonBg,
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
