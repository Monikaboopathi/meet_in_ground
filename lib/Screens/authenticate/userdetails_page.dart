import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:meet_in_ground/util/Services/Auth_service.dart';
import 'package:meet_in_ground/util/Services/PreferencesService.dart';
import 'package:meet_in_ground/util/Services/image_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/util/Services/userName_service.dart';
import 'package:meet_in_ground/util/api/Firebase_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import '../../constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/refferral_service.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

String fcmToken = "";
String referralId = "";

class UserOnBoard extends StatefulWidget {
  final String mobile;
  final String favhero;
  final String favcolor;
  final String password;
  final String confirmpassword;

  const UserOnBoard({
    Key? key,
    required this.mobile,
    required this.favhero,
    required this.favcolor,
    required this.password,
    required this.confirmpassword,
  }) : super(key: key);

  @override
  _UserOnBoardState createState() => _UserOnBoardState();
}

class _UserOnBoardState extends State<UserOnBoard> {
  final List<String> sportNames = [
    "Football",
    "Basketball",
    "Tennis",
    "Cricket",
    "Rugby",
    "Soccer",
    "Golf",
    "Swimming",
    "Baseball"
  ];
  int index = 0;
  String username = "";
  String userCity = "";
  LocationData? userLocation;
  File? selectedImage;
  bool locationLoading = false;
  final picker = ImagePicker();
  bool locationLoader = false;
  List<String> selectedItems = [];
  bool loadingLocation = false;
  final location = Location();

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Get FCM token
    setState(() async {
      fcmToken = await FirebaseApi().getFcmToken();
      referralId = (await RefferalService.getRefferal()) ?? "";
    });

    // Use fcmToken here
    print('FCM Token: $fcmToken');
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
    setState(() {
      locationLoader = true;
      loadingLocation = true;
    });
    final hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      await location.requestPermission();
    }

    final hasService = await location.serviceEnabled();
    if (!hasService) {
      await location.requestService();
    }

    userLocation = await location.getLocation();
    final address = await getAddressFromLatLng(
        userLocation!.latitude!, userLocation!.longitude!);
    setState(() {
      userCity = address;
      locationLoader = false;
      // Disable the button after obtaining location
      loadingLocation = false;
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];

      return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return 'Error getting address';
    }
  }

  void handleShareLocation() async {
    await getLocationAsync();
  }

  void handleIndexChange() {
    if (index == 0 && username.isEmpty) {
      showError("Please Enter User Name");
      return;
    } else if (index == 0 && selectedImage == null) {
      showError("Profile picture is required");
      return;
    } else if (index == 1 && selectedItems.isEmpty) {
      showError("Please select at least one sport");
      return;
    } else if (index == 2 && userLocation == null) {
      showError("Please Share Your Location");
      return;
    }
    if (index == 2) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Loader();
        },
      );
      handleProfile();
    }
    setState(() {
      index = (index + 1) % 3;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> handleProfile() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    String? mobileNo = await PreferencesService.getValue("mobile");
    String? favColor = await PreferencesService.getValue("color");
    String? favHero = await PreferencesService.getValue("hero");
    String? password = await PreferencesService.getValue("password");
    String? cpassword = await PreferencesService.getValue("confirmPassword");
    print(mobileNo);
    print(favColor);
    print(favHero);
    print(password);
    print(cpassword);

    if (userLocation == null) {
      print("User location is null");
      showError("Location not available");
      return;
    }

    if (selectedImage == null) {
      print("Selected image is null");
      showError("Profile picture is required");
      return;
    }

    Map<String, String> formData = {
      'userName': username,
      'sport': selectedItems.join(','),
      'location': '${userLocation!.latitude},${userLocation!.longitude}',
      'referralId': referralId.isEmpty ? "" : referralId,
      'fcmToken': fcmToken,
      'password': widget.password.isEmpty ? password! : widget.password,
      'confirmPassword':
          widget.confirmpassword.isEmpty ? cpassword! : widget.confirmpassword,
      'favoriteColor': widget.favcolor.isEmpty ? favColor! : widget.favcolor,
      'favoriteHero': widget.favhero.isEmpty ? favHero! : widget.favhero,
    };

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '$Base_url/user/addUser/${widget.mobile.isEmpty ? mobileNo : widget.mobile}'),
      );

      request.fields.addAll(formData);

      if (selectedImage != null) {
        final mimeTypeData =
            lookupMimeType(selectedImage!.path, headerBytes: [0xFF, 0xD8])
                ?.split('/');
        final file = await http.MultipartFile.fromPath(
          'profileImg',
          selectedImage!.path,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : MediaType('image', 'jpeg'),
        );
        request.files.add(file);
      }

      final responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('User registration successful');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BottomNavigationScreen(
              currentIndex: 0,
            ),
          ),
          (route) => false,
        );

        Fluttertoast.showToast(
          msg: responseData['message'] ?? 'SUCCESS',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        await AuthService.saveToken("token");
        await MobileNo.saveMobilenumber(
            widget.mobile.isEmpty ? mobileNo! : widget.mobile);
        await UsernameService.saveUserName(username);
        await ImageService.saveImage("${responseData['profileImg']}");
        await RefferalService.clearRefferal();
        await RefferalService.saveRefferal("${responseData['referralId']}");
      } else {
        Fluttertoast.showToast(
          msg: responseData['error'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        await MobileNo.clearMobilenumber();
        print('Failed to register user. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception during user registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Widget>> onboarded = [
      {
        'header': Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 0),
              child: Text('Create your Profile',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ThemeService.textColor)),
            ),
          ],
        ),
        'textInput': Column(
          children: [
            Text(
              'Before you join our safest social Media, let us know who you are',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ThemeService.textColor),
            ),
            SizedBox(height: 46),
            Stack(
              children: [
                selectedImage != null
                    ? CircleAvatar(
                        radius: 80,
                        backgroundImage: FileImage(selectedImage!),
                      )
                    : CircleAvatar(
                        radius: 80,
                        child: Icon(Icons.person, size: 80),
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
            SizedBox(height: 40),
            Row(
              children: [
                Text(
                  'Username',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeService.textColor),
                ),
                Text(
                  '*',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              style: TextStyle(color: ThemeService.textColor),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Square-like borders
                ),
                labelText: 'Username',
                labelStyle: TextStyle(color: ThemeService.textColor),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              ),
              onChanged: (value) {
                setState(() {
                  username = value;
                });
              },
            ),
          ],
        ),
        'subtitle': Text('This will appear as your username to others',
            style: TextStyle(color: ThemeService.textColor)),
      },
      {
        'header': Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 0),
              child: Text('Select Sports',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ThemeService.textColor)),
            ),
          ],
        ),
        'textInput': Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 50, 8, 0),
              child: Wrap(
                spacing: 20,
                children: sportNames.map((sport) {
                  final isSelected = selectedItems.contains(sport);
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ChoiceChip(
                      label: Text(
                        sport,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: ThemeService.buttonBg,
                      backgroundColor: Colors.grey.shade300,
                      selectedShadowColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedItems.add(sport);
                          } else {
                            selectedItems.remove(sport);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        'subtitle': Text('Select minimum 1 sport, maximum 5 sports',
            style: TextStyle(color: ThemeService.textColor)),
      },
      {
        'header': Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 0),
              child: Text('Share Location',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ThemeService.textColor)),
            ),
          ],
        ),
        'textInput': Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'assets/location.json',
                width: 350,
                height: 350,
              ),
            ),
            SizedBox(height: 30),
            if (loadingLocation)
              CircularProgressIndicator()
            else if (userLocation != null)
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    userCity,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ThemeService.textColor),
                  )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                loadingLocation ? null : handleAddLocation();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor:
                    loadingLocation ? Colors.grey : ThemeService.buttonBg,
              ),
              child: const Text(
                'Share Location',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
        'subtitle': Text(
          'Share your Location for Identity',
          style: TextStyle(color: ThemeService.textColor),
        ),
      },
    ];

    return Scaffold(
      backgroundColor: ThemeService.background,
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            onboarded[index]['header']!,
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    onboarded[index]['textInput']!,
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                onboarded[index]['subtitle']!,
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: handleIndexChange,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: ThemeService.buttonBg,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${index + 1} / ${onboarded.length}',
                  style: TextStyle(color: ThemeService.textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
