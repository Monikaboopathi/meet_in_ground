import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';

class ReferredUsers extends StatefulWidget {
  @override
  _ReferredUsersState createState() => _ReferredUsersState();
}

class _ReferredUsersState extends State<ReferredUsers> {
  String userPhone = '';
  List<dynamic> referralDetails = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();

    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await refetchUserDetails();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    String? userNumber = await MobileNo.getMobilenumber();
    setState(() {
      userPhone = userNumber!;
    });
    await refetchUserDetails();
  }

  Future<void> refetchUserDetails() async {
    final response = await http.get(
      Uri.parse('https://bet-x-new.onrender.com/user/referredUsers/$userPhone'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        referralDetails = data['data']['referredUsers'];
        isLoading = false;
      });
    } else {
      // Handle the error
      setState(() {
        isLoading = false;
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
          'Referred Users',
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
          ? Center(child: CircularProgressIndicator())
          : referralDetails.isNotEmpty
              ? SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: referralDetails.map((referral) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ThemeService.buttonBg,width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: referral['profileImage'] != null
                                    ? NetworkImage(referral['profileImage']) as ImageProvider
                                    : AssetImage('assets/images/empty-img.jpg'),
                              ),
                              SizedBox(width: 15),
                              Text(
                                referral['userName'][0].toUpperCase() + referral['userName'].substring(1),
                                style: TextStyle(color: ThemeService.textColor,fontSize: 18,fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              : NoDataFoundWidget(),
    );
  }
}
