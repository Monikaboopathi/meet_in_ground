import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meet_in_ground/Ads/BannerAd.dart';
import 'package:meet_in_ground/Ads/InterstitialAd.dart';
import 'package:meet_in_ground/Ads/NativeAd.dart';
import 'package:meet_in_ground/Ads/RewardAds.dart';
import 'package:meet_in_ground/Screens/Posts/MyPosts.dart';
import 'package:meet_in_ground/constant/sports_names.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/util/Services/userName_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class Addposts extends StatefulWidget {
  @override
  _AddpostsState createState() => _AddpostsState();
}

class _AddpostsState extends State<Addposts> {
  File? selectedImage;
  String? selectedValue;
  String? postText;
  String? location;
  double? price;
  DateTime date = DateTime.now();
  bool showPicker = false;
  final picker = ImagePicker();
  bool isLoading = false;

  String? sportError;
  String? dateError;
  String? locationError;
  String? matchDetailsError;
  String? priceError;
  final NativeAdsController nativeAdController = Get.put(NativeAdsController());
  @override
  void initState() {
    nativeAdController.loadAd();
    super.initState();
  }

  bool _validateFields() {
    bool isValid = true;
    setState(() {
      if (selectedValue == null) {
        sportError = "Please select a sport";
        isValid = false;
      } else {
        sportError = null;
      }

      if (location == null || location!.isEmpty) {
        locationError = "Please enter a Location";
        isValid = false;
      } else {
        locationError = null;
      }

      if (price == null || price! <= 0) {
        priceError = "Please enter a Bet Amount";
        isValid = false;
      } else {
        priceError = null;
      }

      if (postText == null || postText!.isEmpty) {
        matchDetailsError = "Please enter Match details";
        isValid = false;
      } else {
        matchDetailsError = null;
      }
    });
    return isValid;
  }

  Future<void> _handleSubmit() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    if (_validateFields()) {
      String? userMobileNumber = await MobileNo.getMobilenumber();
      String? userName = await UsernameService.getUserName();
      print(userMobileNumber);
      print(userName);

      Map<String, String> formData = {
        "userName": userName ?? "",
        "sport": selectedValue ?? "",
        "matchDetails": postText ?? "",
        "matchDate": DateFormat('dd/MM/yyyy').format(date),
        "betAmount": price?.toString() ?? "",
        "placeOfMatch": location ?? "",
      };

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$Base_url/post/addPost/$userMobileNumber'),
        );

        request.fields.addAll(formData);

        if (selectedImage != null) {
          final mimeTypeData =
              lookupMimeType(selectedImage!.path, headerBytes: [0xFF, 0xD8])
                  ?.split('/');
          final file = await http.MultipartFile.fromPath(
            'image',
            selectedImage!.path,
            contentType: mimeTypeData != null
                ? MediaType(mimeTypeData[0], mimeTypeData[1])
                : MediaType('image', 'jpeg'),
          );
          print(file);
          request.files.add(file);
        }
        final response = await request.send();
        print(formData);
        if (response.statusCode == 200) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyPosts()),
          );
          Fluttertoast.showToast(
            msg: "Post Added Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          print('Post request successful');
        } else {
          print('Post request failed with status: ${response.statusCode}');
          print(
              'Post request failed with status: ${response.request.toString()}');
          Fluttertoast.showToast(
            msg: "Failed to submit post. Please try again later.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (error) {
        print('Error: $error');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all the required fields'),
      ));
    }
  }

  // Future<List<String>> placeAutocomplete(String query) async {
  //   final String url =
  //       'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  //   final Uri uri = Uri.https(
  //     'maps.googleapis.com',
  //     '/maps/api/place/autocomplete/json',
  //     {
  //       'input': query,
  //       'key': 'AIzaSyDtceUAXXYeNr95KedulYGhuM-izzY4kXU',
  //     },
  //   );

  //   final http.Response response = await http.get(uri);

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     final List<dynamic> predictions = data['predictions'];
  //     print('Predictions: $predictions'); // Log predictions for debugging
  //     return predictions
  //         .map((prediction) => prediction['description'] as String)
  //         .toList();
  //   } else {
  //     print(
  //         'Failed to fetch autocomplete suggestions with status code: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //     throw Exception('Failed to fetch autocomplete suggestions');
  //   }
  // }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != date)
      setState(() {
        date = picked;
      });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ThemeService.background,
        title: Text(
          'Add Post',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: ThemeService.background,
      body: WillPopScope(
         onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 0),
            ),
          );
          return false;
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: pickImage,
                    child: Center(
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: ThemeService.buttonBg, width: 3),
                        ),
                        child: selectedImage == null
                            ? Center(
                                child: Icon(Icons.add_a_photo,
                                    color: Colors.grey[800], size: 100),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(selectedImage!,
                                    fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Sport*',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeService.textColor)),
                            SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedValue,
                                underline: Container(), // Remove the underline
                                items: sportNames.map((sport) {
                                  return DropdownMenuItem<String>(
                                    value: sport,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      child: Text(
                                        sport,
                                        style: TextStyle(
                                            color: ThemeService.textColor),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value;
                                    sportError = null;
                                  });
                                },
                                hint: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Select Sport',
                                    style: TextStyle(
                                        color: ThemeService.textColor),
                                  ),
                                ),
                              ),
                            ),
                            if (sportError != null)
                              Text(sportError!,
                                  style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Date*',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeService.textColor)),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      _formatDate(date),
                                      style: TextStyle(
                                          color: ThemeService.textColor),
                                    ),
                                    Icon(Icons.calendar_today,
                                        color: ThemeService.textColor),
                                  ],
                                ),
                              ),
                            ),
                            if (dateError != null)
                              Text(dateError!,
                                  style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Location*',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ThemeService.textColor)),
                  SizedBox(height: 5),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your Location here',
                      hintStyle: TextStyle(color: ThemeService.textColor),
                    ),
                    onChanged: (text) async {
                      setState(() {
                        location = text;
                        locationError = null;
                      });
                      // final List<String> suggestions =
                      //     await placeAutocomplete(text);
                      // print('Predictions: $suggestions');
                    },
                  ),
                  if (locationError != null)
                    Text(locationError!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  Text('Bet Amount*',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ThemeService.textColor)),
                  SizedBox(height: 5),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your Bet Amount here',
                      hintStyle: TextStyle(color: ThemeService.textColor),
                    ),
                    onChanged: (text) {
                      setState(() {
                        price = double.tryParse(text);
                        priceError = null;
                      });
                    },
                  ),
                  if (priceError != null)
                    Text(priceError!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  Text('Match details*',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ThemeService.textColor)),
                  SizedBox(height: 5),
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write your post here...',
                      hintStyle: TextStyle(color: ThemeService.textColor),
                    ),
                    onChanged: (text) {
                      setState(() {
                        postText = text;
                        matchDetailsError = null;
                      });
                    },
                  ),
                  if (matchDetailsError != null)
                    Text(matchDetailsError!,
                        style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MyPosts()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        side: BorderSide(
                          color: ThemeService.buttonBg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'My Post',
                        style: TextStyle(
                          fontSize: 20,
                          color: ThemeService.buttonBg,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        _handleSubmit();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: ThemeService.buttonBg,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  AdMobBanner(),
                  AdMobInterstitial(),
                  AdMobReward(),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Loader(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
