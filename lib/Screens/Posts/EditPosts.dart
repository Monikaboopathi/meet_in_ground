import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meet_in_ground/Screens/Posts/MyPosts.dart';
import 'package:meet_in_ground/constant/results.dart';
import 'package:meet_in_ground/constant/sports_names.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class EditPost extends StatefulWidget {
  final String postId;
  EditPost({Key? key, required this.postId}) : super(key: key);
  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  File? selectedImage;
  String? selectedValue;
  String? selectedResult;
  String? imageUrl;
  String? postText;
  String? location;
  double? price;
  DateTime date = DateTime.now();
  bool showPicker = false;
  bool isLoading = false;
  final picker = ImagePicker();

  String? sportError;
  String? resultError;
  String? dateError;
  String? locationError;
  String? matchDetailsError;
  String? priceError;
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController matchDetailsController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchPostData();
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
      if (selectedResult == null) {
        resultError = "Please select a Result";
        isValid = false;
      } else {
        resultError = null;
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

  Future<void> fetchPostData() async {
    String Base_url =
        "https://bet-x-new.onrender.com/post/viewMyPostById/${widget.postId}";
    setState(() {
      isLoading = true;
    });

    try {
      String apiUrl = Base_url;
      var response = await http.get(Uri.parse(apiUrl));
      final data = json.decode(response.body)['data'];

      if (response.statusCode == 200) {
        date = DateTime.parse(data['matchDate']);
        selectedValue = data['sport'];
        priceController.text = data['betAmount'].toString();
        locationController.text = data['placeOfMatch'].toString();
        matchDetailsController.text = data['matchDetails'];
        selectedResult = data['result'] == null ? "----" : data['result'];

        imageUrl = data['image'];
        price = double.parse(data['betAmount'].toString());
        location = data['placeOfMatch'];
        postText = data['matchDetails'];
      }
    } catch (exception) {
      print('Error fetching post data: $exception');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_validateFields()) {
      String? userMobileNumber = await MobileNo.getMobilenumber();
      print(userMobileNumber);

      Map<String, String> postData = {
        "sport": selectedValue ?? "",
        "matchDetails": postText ?? "",
        "matchDate": date.toString(),
        "betAmount": price.toString(),
        "placeOfMatch": location ?? "",
        "result": selectedResult == '----' ? null ?? "" : selectedResult ?? ""
      };

      // Add the "image" field conditionally
      if (imageUrl != null && imageUrl!.isNotEmpty) {
        postData["image"] = imageUrl!;
      } else if (selectedImage != null) {
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
        // Do not include the file object directly in the postData map
        // Instead, handle it separately in the request body
      }

      // Convert the data to JSON
      String jsonString = json.encode(postData);

      // Make the API PATCH request
      try {
        http.MultipartRequest request = http.MultipartRequest(
          'PATCH',
          Uri.parse(
              'https://bet-x-new.onrender.com/post/updatePost/${widget.postId}'),
        );
        request.headers['Content-Type'] = 'application/json';
        request.fields.addAll(postData);

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

          // Add the image file to the request
          request.files.add(file);
        }

        final response = await request.send();
        final String responseString = await response.stream.bytesToString();
        final Map<String, dynamic> responseData = json.decode(responseString);

        // Check the response status
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: responseData['message'] ?? "Post Added Successfully..!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyPosts()),
          );
        } else {
          print('Post request failed with status: ${response.statusCode}');
          Fluttertoast.showToast(
            msg: responseData['error'] ??
                "Failed to submit post. Please try again later..!!",
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
        imageUrl = "";
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
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: ThemeService.background,
        title: Text(
          'Edit Post',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: ThemeService.background,
      body: isLoading
          ? Loader()
          : SingleChildScrollView(
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
                          child: (imageUrl ?? '').isEmpty
                              ? selectedImage == null
                                  ? Center(
                                      child: Icon(Icons.add_a_photo,
                                          color: Colors.grey[800], size: 100),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(selectedImage!,
                                          fit: BoxFit.cover),
                                    )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
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
                                )),
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
                    controller: locationController,
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
                    controller: priceController,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Result*',
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
                          value: selectedResult,
                          underline: Container(), // Remove the underline
                          items: results.map((result) {
                            return DropdownMenuItem<String>(
                              value: result,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                child: Text(
                                  result,
                                  style:
                                      TextStyle(color: ThemeService.textColor),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedResult = value;
                              resultError = null;
                            });
                          },
                          hint: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Select Result',
                              style: TextStyle(color: ThemeService.textColor),
                            ),
                          ),
                        ),
                      ),
                      if (resultError != null)
                        Text(resultError!, style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Match details*',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ThemeService.textColor)),
                  SizedBox(height: 5),
                  TextField(
                    controller: matchDetailsController,
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
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Loader();
                          },
                        );

                        await Future.delayed(Duration(seconds: 1));

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
