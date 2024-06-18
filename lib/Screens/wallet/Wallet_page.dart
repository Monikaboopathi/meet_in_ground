import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:http/http.dart' as http;
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';
import 'package:meet_in_ground/widgets/Refer&Earn.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  TextEditingController _textController = TextEditingController();
  String _textError = '';
  bool _visible = false;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  Color _checkColor1 = ThemeService.primary;
  Color _checkColor2 = ThemeService.primary;
  String _balance = '';
  List<Map<String, dynamic>> _withdrawalHistory = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchWithdrawalHistory();
  }

  Future<void> _fetchData() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    String? userMobileNumber = await MobileNo.getMobilenumber();
    print(userMobileNumber);

    final url = Uri.parse('$Base_url/user/walletDetails/$userMobileNumber');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _balance = data['data']['walletBalance'].toString();
        });
      } else {
        print('Failed to load wallet balance');
      }
    } catch (e) {
      print('Error fetching wallet balance: $e');
    }
  }

  void _handleSubmit() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    setState(() {
      _textError = '';
    });

    String trimmedText = _textController.text.trim();

    if (trimmedText.isEmpty) {
      setState(() {
        _textError = 'Please enter your UPI ID.';
      });
      return;
    }

    RegExp upiRegex = RegExp(r'^[a-zA-Z0-9\.\-_]+@[a-zA-Z]+$');
    if (!upiRegex.hasMatch(trimmedText)) {
      setState(() {
        _textError = 'Invalid UPI ID format.';
      });
      return;
    }

    if (!_isChecked1) {
      setState(() {
        _checkColor1 = Colors.red;
      });
      return;
    }

    if (!_isChecked2) {
      setState(() {
        _checkColor2 = Colors.red;
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    String? userMobileNumber = await MobileNo.getMobilenumber();

    final url = Uri.parse('$Base_url/user/withdrawRequest/$userMobileNumber');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'upiID': trimmedText}),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData);

      if (response.statusCode == 200) {
        setState(() {
          _visible = false;
          _textController.clear();
          _isChecked1 = false;
          _isChecked2 = false;
        });
        await _fetchData();
        await _fetchWithdrawalHistory();
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: responseData['error'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print('Error submitting withdraw request: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchWithdrawalHistory() async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    String? userMobileNumber = await MobileNo.getMobilenumber();
    final url =
        Uri.parse('$Base_url/user/viewMyWithdrawRequests/$userMobileNumber');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _withdrawalHistory = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        print('Failed to load withdrawal history');
      }
    } catch (e) {
      print('Error fetching withdrawal history: $e');
    }
  }

  void _toggleCheckbox1() {
    setState(() {
      _isChecked1 = !_isChecked1;
      _checkColor1 = _isChecked1 ? ThemeService.primary : Colors.red;
    });
  }

  void _toggleCheckbox2() {
    setState(() {
      _isChecked2 = !_isChecked2;
      _checkColor2 = _isChecked2 ? ThemeService.primary : Colors.red;
    });
  }

  Future<void> _refresh() async {
    await _fetchData();
    await _fetchWithdrawalHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (notification) => false,
        automaticallyImplyLeading: true,
        backgroundColor: ThemeService.background,
        title: Text(
          'Wallet',
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
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 4),
            ),
          );
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹ $_balance',
                            style: TextStyle(
                                fontSize: 24,
                                color: ThemeService.textColor,
                                fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ReferEarn(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: ThemeService.buttonBg,
                              padding: EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 15),
                            ),
                            child: Text(
                              'Refer & Earn',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Minimum withdrawal limit should be ',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ThemeService.textColor),
                        ),
                        Text(
                          '₹50',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Withdrawal History',
                          style: TextStyle(
                              fontSize: 18,
                              color: ThemeService.textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.swap_vert,
                            color: ThemeService.placeHolder, size: 26),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Expanded(
                      child: _withdrawalHistory.isEmpty
                          ? Center(
                              child: NoDataFoundWidget(errorText: "No transactions yet",),
                            )
                          : ListView.builder(
                              itemCount: _withdrawalHistory.length,
                              itemBuilder: (context, index) {
                                var transaction = _withdrawalHistory[index];
                                return Stack(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: ThemeService.primary,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'UPI ID: ',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ThemeService
                                                              .textColor),
                                                    ),
                                                    Text(
                                                      '${transaction['upiID']}',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: ThemeService
                                                              .textColor),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '₹${transaction['amount']}',
                                                  style: TextStyle(
                                                      color:
                                                          ThemeService.primary,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.0),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Requested on: ',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ThemeService
                                                              .textColor),
                                                    ),
                                                    Text(
                                                      '${transaction['createdAt'].split(" ")[0]}',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: ThemeService
                                                              .textColor),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Approved on: ',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ThemeService
                                                              .textColor),
                                                    ),
                                                    Text(
                                                      '${transaction['status'] == "Pending" ? "----" : transaction['updatedAt'].split(" ")[0]}',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: ThemeService
                                                              .textColor),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 4,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2.0, horizontal: 13.0),
                                        decoration: BoxDecoration(
                                          color:
                                              transaction['status'] == "Pending"
                                                  ? Colors.orange
                                                  : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            transaction['status'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: ThemeService.buttonBg,
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    child: Text(
                      'Withdraw',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => setState(() {
                      _visible = true;
                    }),
                  ),
                ),
              ),
              _buildModal(),
              if (isLoading) Loader()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModal() {
    return Visibility(
      visible: _visible,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: ThemeService.primary, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () => setState(() {
                      _visible = false;
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 10, 25, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Please enter your UPI Id',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          Text(
                            '*',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'sam.wilson@upi',
                          errorText: _textError.isNotEmpty ? _textError : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked1,
                            onChanged: (bool? value) {
                              _toggleCheckbox1();
                            },
                          ),
                          Expanded(
                            child: Text(
                              'I accept this is a valid UPI Id',
                              style: TextStyle(color: _checkColor1),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked2,
                            onChanged: (bool? value) {
                              _toggleCheckbox2();
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Save this UPI Id for Future Withdrawals',
                              style: TextStyle(color: _checkColor2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: ThemeService.buttonBg,
                          padding: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 25),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
