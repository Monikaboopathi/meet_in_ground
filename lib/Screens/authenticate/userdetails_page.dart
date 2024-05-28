import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import '../../constant/themes_service.dart';
import '../util/Services/refferral_service.dart';

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
    fetchLocationInfo(userLocation!.latitude!, userLocation!.longitude!);

    setState(() {
      locationLoader = false;
      loadingLocation = false;
    });
  }

Future<void> pickImage() async {
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      selectedImage = File(pickedFile.path);
    });

    // Convert image path to a File object
    String filePath = pickedFile.path;

    // Call handleProfile with the File object
    handleProfile(File(filePath));
  }
}



  Future<void> fetchLocationInfo(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json'));
    final data = jsonDecode(response.body);
    setState(() {
      userCity = data['display_name'] ?? '';
    });
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
      index = (index + 1) % 3; // Assuming there are 3 onboarding steps
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> handleProfile([File? file]) async {

    String apiUrl =
        'https://bet-x-new.onrender.com/user/addUser/${widget.mobile}';
    Map<String, dynamic> body = {
      'userName': username,
      'sport': selectedItems
          .join(','), // Joining selected sports into a single string
      'location': '${userLocation!.latitude},${userLocation!.longitude}',
      'profileImg': file,
      'referralId': referralId,
      'fcmToken': fcmToken,
      'password': widget.password,
      'confirmPassword': widget.confirmpassword,
      'favoriteColor': widget.favcolor,
      'favoriteHero': widget.favhero,
    };
    print(username);
    print(selectedItems);
    print(selectedImage!);
    print(userLocation!.latitude);
    print(userLocation!.longitude);
    print(referralId);
    print(fcmToken);
    print(widget.password);
    print(widget.confirmpassword);
    print(widget.favcolor);
    print(widget.favhero);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
 // Parse the response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Handle success
        print('User registration successful');
            Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavigationScreen(),
          ),
        );
        Fluttertoast.showToast(
          msg: 'SUCCESS',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // String email = responseData['phoneNumber'];
        await MobileNo.saveMobilenumber(widget.mobile);
        await RefferalService.clearRefferal();
        await RefferalService.saveRefferal("${responseData['referralId']}");
    
      } else {
         Fluttertoast.showToast(
          msg: responseData['message'],
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
      // Handle exceptions
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        'textInput': Column(
          children: [
            Text(
              'Before you join our safest social Media, let us know who you are',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Square-like borders
                ),
                labelText: 'Username',
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
        'subtitle': Text('This will appear as your username to others'),
      },
      {
        'header': Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 0),
              child: Text('Select Sports',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
        'subtitle': Text('Select minimum 1 sport, maximum 5 sports'),
      },
      {
        'header': Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 0),
              child: Text('Share Location',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        'textInput': Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: loadingLocation
                  ? CircularProgressIndicator()
                  : Lottie.asset(
                      'assets/location.json',
                      width: 350,
                      height: 350,
                    ),
            ),
            SizedBox(height: 30),
            if (userLocation != null)
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    userCity,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (locationLoading) CircularProgressIndicator();
                handleAddLocation();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: ThemeService.buttonBg,
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
        'subtitle': Text('Share your Location for Identity'),
      },
    ];

    return Scaffold(
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
                Text('${index + 1} / ${onboarded.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
