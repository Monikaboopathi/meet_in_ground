import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as Location;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:meet_in_ground/constant/sports_names.dart';

import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userDetails;
  double lat;
  double lng;

  EditProfile(
      {required this.userDetails, required this.lat, required this.lng});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _locationController = TextEditingController();
  File? _selectedImage;
  String? imageUrl;
  List<String> _selectedSports = [];
  bool _isLocationLoading = false;
  Location.LocationData? userLocation;
  final location = Location.Location();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userDetails['userName']);
    _locationController =
        TextEditingController(text: widget.userDetails['location']);
    imageUrl = widget.userDetails['profileImg'];
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
        _selectedImage = File(pickedFile.path);
        imageUrl = "";
      });
    }
  }

  Future<void> handleLocation() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    setState(() {
      _isLocationLoading = true;
    });

    Location.Location location = Location.Location();
    Location.LocationData? locationData;

    try {
      locationData = await location.getLocation();
      setState(() {
        widget.lat = locationData!.latitude!;
        widget.lng = locationData.longitude!;
        _isLocationLoading = false;
      });
    } catch (error) {
      print('Error getting location: $error');
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> handleSave() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
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

    setState(() {
      isLoading = true;
    });
    String? userMobileNumber = await MobileNo.getMobilenumber();
    print(userMobileNumber);

    // Add the "image" field conditionally
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      widget.userDetails['profileImg'] = imageUrl!;
    } else if (_selectedImage != null) {
      final mimeTypeData =
          lookupMimeType(_selectedImage!.path, headerBytes: [0xFF, 0xD8])
              ?.split('/');
      final file = await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
        contentType: mimeTypeData != null
            ? MediaType(mimeTypeData[0], mimeTypeData[1])
            : MediaType('image', 'jpeg'),
      );
      // Do not include the file object directly in the postData map
      // Instead, handle it separately in the request body
    }

    // Convert the data to JSON

    try {
      String url = '$Base_url/user/updateUser/$userMobileNumber';
      String username = _usernameController.text.trim();
      String sports = _selectedSports.join(',');
      String location = _locationController.text.trim();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      Map<String, dynamic> body = {
        'userName': username,
        'sport': sports,
        'location': '${widget.lat},${widget.lng}',
      };
      print(username);
      print(sports);
      print(location);

      final request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields
          .addAll(body.map((key, value) => MapEntry(key, value.toString())));

      if (_selectedImage != null) {
        final mimeTypeData =
            lookupMimeType(_selectedImage!.path, headerBytes: [0xFF, 0xD8])
                ?.split('/');
        final file = await http.MultipartFile.fromPath(
          'profileImg',
          _selectedImage!.path,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : MediaType('image', 'jpeg'),
        );
        request.files.add(file);
      }

      final response = await request.send();
      final String responseString = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = json.decode(responseString);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavigationScreen(currentIndex: 4),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to update profile",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleAddLocation() async {
    final hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.granted) {
      await getLocationAsync();
    } else if (hasPermission == PermissionStatus.denied) {
      // Request location permission
      final status = await location.requestPermission();
      if (status == PermissionStatus.granted) {
        await getLocationAsync();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location permission denied.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Location permission denied forever. Please enable it in app settings.'),
      ));
    }
  }

  Future<void> getLocationAsync() async {
    // final hasPermission = await location.hasPermission();
    // if (hasPermission == PermissionStatus.denied) {
    //   await location.requestPermission();
    // }

    // final hasService = await location.serviceEnabled();
    // if (!hasService) {
    //   await location.requestService();
    // }

    try {
      userLocation = await location.getLocation();
      _locationController.text = await getAddressFromLatLng(
          userLocation!.latitude!, userLocation!.longitude!);
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch location. Please try again.'),
      ));
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    print(lat);
    print(lng);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];
      print(
          "======================================================1===========");

      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return 'Error getting address';
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
                      value: tempSelectedSports.contains(sport),
                      title: Text(sport),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedSports.add(sport);
                          } else {
                            tempSelectedSports.remove(sport);
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
      body: isLoading
          ? Loader()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            border: Border.all(
                              color: ThemeService.buttonBg,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: (imageUrl ?? '').isEmpty
                                ? _selectedImage == null
                                    ? Center(
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey[800],
                                          size: 100,
                                        ),
                                      )
                                    : Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                : Image.network(
                                    imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[
                                            300], // Placeholder color in case of error
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.red, // Error icon color
                                        ),
                                      );
                                    },
                                  ),
                          ),
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
                            padding: EdgeInsets.symmetric(
                                vertical: _isLocationLoading ? 16 : 3.0,
                                horizontal: 8.0),
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
                                          readOnly: true,
                                          onTap: () => handleLocation,
                                          keyboardType: TextInputType.none,
                                          decoration: InputDecoration(
                                            hintText: 'Select your location',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                ),
                                Icon(Icons.location_on,
                                    color: Colors.grey[600]),
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
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 8.0),
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
