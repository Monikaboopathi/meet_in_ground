// ignore_for_file: unused_element, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

class RateUsDialog extends StatefulWidget {
  const RateUsDialog({
    Key? key,
  }) : super(key: key);

  @override
  _RateUsDialogState createState() => _RateUsDialogState();
}

class _RateUsDialogState extends State<RateUsDialog> {
  late String ratings;
  late TextEditingController feedbackController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String url =
      "https://play.google.com/store/apps/details?id=com.trainsonwheels.trainsonwheelsandroidapp";

  bool isLoading = false;
  bool showComments = false;

  @override
  void initState() {
    super.initState();
    ratings = "";
    feedbackController = TextEditingController();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> handleRateUs() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);

    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('$Base_url/user/addRating/8072974576'),
        body: jsonEncode(
            {"rating": ratings, "comments": feedbackController.text}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(
        //   msg: responseData['message'],
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.TOP,
        //   timeInSecForIosWeb: 2,
        //   backgroundColor: Colors.green,
        //   textColor: Colors.white,
        // );
        Navigator.pop(context);
        showDialogThanks(context);
      } else {
        Fluttertoast.showToast(
          msg: responseData['error'] ?? '',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (exception) {
      // await Sentry.captureException(
      //   exception,
      //   stackTrace: stackTrace,
      // );
    } finally {
      setState(() {
        isLoading = false;
        showComments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: AlertDialog(
            insetPadding: EdgeInsets.all(2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Enjoying Trains On Wheels?",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: ThemeService.textColor),
                                ),
                                Text(
                                  "Rate your experience with us!",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 8,
                                      color: Colors.grey),
                                ),
                              ],
                            )),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 30,
                              color: ThemeService.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40,
                      itemPadding: EdgeInsets.symmetric(horizontal: 5),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: ThemeService.primary,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                        setState(() {
                          ratings = rating.toString();

                          if (rating != 5.0) {
                            setState(() {
                              showComments = true;
                            });
                          } else {
                            setState(() {
                              showComments = false;
                            });
                          }
                        });
                      },
                    ),
                    showComments
                        ? Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: feedbackController,
                                  decoration: InputDecoration(
                                    labelText: 'Write your feedback/suggestion',
                                    labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: ThemeService.textColor),
                                  ),
                                  maxLines: null,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your feedback/suggestion';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // var connectivityResult =
                                      //     await Connectivity()
                                      //         .checkConnectivity();
                                      // if (connectivityResult ==
                                      //     ConnectivityResult.none) {
                                      //   showNotInternetDialog(context);
                                      //   return;
                                      // }

                                      closeKeyboard(context);
                                      if (_formKey.currentState!.validate()) {
                                        handleRateUs();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      backgroundColor: ThemeService.buttonBg,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ratings == "5.0"
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Great! We ensure to make your journey amazing",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 8,
                                        color: Colors.grey),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _launchUrl();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        backgroundColor: ThemeService.buttonBg,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Rate us on Play Store",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading) Loader()
      ],
    );
  }

  void closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(url);
    if (!await canLaunch(_url.toString())) {
      throw Exception('Could not launch $_url');
    }
    await launch(_url.toString());
  }
}

void showDialogThanks(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(15),
      child: AlertDialog(
        insetPadding: EdgeInsets.all(2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Thank you for your feedback!",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "We'll take your feedback to improve our app",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 8,
                      color: Colors.grey),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: ThemeService.buttonBg,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Okay",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void showDialogRateUs(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => RateUsDialog(),
  );
}
