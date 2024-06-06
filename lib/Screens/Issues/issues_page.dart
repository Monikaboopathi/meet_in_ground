import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ReportIssuesPage extends StatefulWidget {
  @override
  _ReportIssuesPageState createState() => _ReportIssuesPageState();
}

class _ReportIssuesPageState extends State<ReportIssuesPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _subjectError = '';
  String _messageError = '';
  File? _selectedImage;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);

    setState(() {
      _subjectError = _subjectController.text.trim().isEmpty
          ? 'Subject cannot be empty'
          : '';
      _messageError = _messageController.text.trim().isEmpty
          ? 'Message cannot be empty'
          : '';
    });

    String message = _messageController.text;
    String subject = _subjectController.text;
    String? userMobileNumber = await MobileNo.getMobilenumber();
    print(userMobileNumber);

    if (_subjectError.isEmpty && _messageError.isEmpty) {
      try {
        var uri = Uri.parse('$Base_url/user/addIssues/$userMobileNumber');
        var request = http.MultipartRequest('POST', uri);
        request.fields['subject'] = subject;
        request.fields['message'] = message;

        if (_selectedImage != null) {
          final mimeTypeData =
              lookupMimeType(_selectedImage!.path, headerBytes: [0xFF, 0xD8])
                  ?.split('/');
          final file = await http.MultipartFile.fromPath(
            'screenshotImg',
            _selectedImage!.path,
            contentType: mimeTypeData != null
                ? MediaType(mimeTypeData[0], mimeTypeData[1])
                : MediaType('image', 'jpeg'),
          );

          // Debug prints
          print('--------------------------------------------------------');
          print('File path: ${_selectedImage!.path}');
          print('File size: ${await _selectedImage!.length()}');
          print('MIME type: ${file.contentType}');

          request.files.add(file);
        }

        var response = await request.send();
        var responseBody = await http.Response.fromStream(response);

        final Map<String, dynamic> responseData = jsonDecode(responseBody.body);

        print(responseData);

        if (response.statusCode == 200) {
          _messageController.clear();
          _subjectController.clear();

          setState(() {
            _selectedImage = null;
          });

          Fluttertoast.showToast(
            msg: responseData['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          print('Issue reported successfully');
        } else {
          Fluttertoast.showToast(
            msg: responseData['error'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          print('Failed to report issue: ${responseBody.body}');
        }
      } catch (e) {
        print('Error reporting issue: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (notification) => false,
        automaticallyImplyLeading: true,
        backgroundColor: ThemeService.background,
        title: Text(
          'Report Issues',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Did you face any issues in our services? Please let us know your thoughts. We’ll try to solve your concern as soon as possible!',
                      style: TextStyle(
                          fontSize: 16.0, color: ThemeService.textColor),
                    ),
                    SizedBox(height: 16.0),
                    _buildInputField(
                      label: 'Subject',
                      controller: _subjectController,
                      errorText: _subjectError,
                    ),
                    SizedBox(height: 16.0),
                    _buildInputField(
                      label: 'Message',
                      controller: _messageController,
                      errorText: _messageError,
                      maxLines: 5,
                    ),
                    SizedBox(height: 16.0),
                    Text('Have any Screenshots? (Optional)',
                        style: TextStyle(
                            fontSize: 16.0, color: ThemeService.textColor)),
                    SizedBox(height: 8.0),
                    _buildImagePicker(),
                    SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
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
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String errorText = '',
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: '$label ',
            children: [
              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
            ],
          ),
          style: TextStyle(fontSize: 16.0, color: ThemeService.textColor),
        ),
        SizedBox(height: 8.0),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: ThemeService.textColor),
          decoration: InputDecoration(
            hintText: 'Type your $label here',
            hintStyle: TextStyle(color: ThemeService.textColor),
            errorText: errorText.isEmpty ? null : errorText,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Row(
      children: [
        _selectedImage != null
            ? Image.file(
                _selectedImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
            : SizedBox.shrink(),
        SizedBox(width: 16.0),
        IconButton(
          icon: Icon(
            Icons.add_a_photo,
            color: ThemeService.textColor,
            size: 80,
          ),
          onPressed: pickImage,
        ),
      ],
    );
  }
}
