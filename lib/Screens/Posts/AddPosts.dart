import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meet_in_ground/constant/sports_names.dart';
import 'package:meet_in_ground/constant/themes_service.dart'; // Ensure you have this import for DateFormat
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/Loader.dart';

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

  String? sportError;
  String? dateError;
  String? locationError;
  String? matchDetailsError;
  String? priceError;

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

  Future<void> _handleSubmit([File? file]) async {
    if (_validateFields()) {

        String? userMobileNumber = await MobileNo.getMobilenumber();
      print(userMobileNumber);

      Map<String, dynamic> postData = {
        "userName": "Ranjith",
        "sport": selectedValue,
        "matchDetails": postText,
        "matchDate": DateFormat('dd/MM/yyyy').format(date),
        "betAmount": price.toString(),
        "placeOfMatch": location,
        "image": file
      };

      // Convert the data to JSON
      String jsonString = json.encode(postData);

      // Make the API post request
      try {
        final response = await http.post(
          Uri.parse('https://bet-x-new.onrender.com/post/addPost/$userMobileNumber'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonString,
        );

        // Check the response status
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Post Added Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(
          //     builder: (context) =>
          //   ),
          // );

          print('Post request successful');
        } else {
          print('Post request failed with status: ${response.statusCode}');
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
        // Handle any exceptions that might occur during the request
        print('Error: $error');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all the required fields'),
      ));
    }
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
      _handleSubmit(File(filePath));
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
    return DateFormat('dd-MM-yyyy').format(date);
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
      body: SingleChildScrollView(
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
                    border: Border.all(color: ThemeService.buttonBg, width: 3),
                  ),
                  child: selectedImage == null
                      ? Center(
                          child: Icon(Icons.add_a_photo,
                              color: Colors.grey[800], size: 100),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
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
                                  style:
                                      TextStyle(color: ThemeService.textColor),
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
                              style: TextStyle(color: ThemeService.textColor),
                            ),
                          ),
                        ),
                      ),
                      if (sportError != null)
                        Text(sportError!, style: TextStyle(color: Colors.red)),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                _formatDate(date),
                                style: TextStyle(color: ThemeService.textColor),
                              ),
                              Icon(Icons.calendar_today,
                                  color: ThemeService.textColor),
                            ],
                          ),
                        ),
                      ),
                      if (dateError != null)
                        Text(dateError!, style: TextStyle(color: Colors.red)),
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
              onChanged: (text) {
                setState(() {
                  location = text;
                  locationError = null;
                });
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
              Text(matchDetailsError!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/MyPosts");
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
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Loader();
                      },
                    );
                    // Delay for 2 seconds to show the loader
                    await Future.delayed(Duration(seconds: 2));

                    // Dismiss the loader and return to the previous page
                    Navigator.pop(context);
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
          ],
        ),
      ),
    );
  }
}
