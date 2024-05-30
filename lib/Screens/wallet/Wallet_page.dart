import 'package:flutter/material.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';

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
  Color _checkColor1 = Colors.black;
  Color _checkColor2 = Colors.black;
  String _balance = '0';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {}

 void _handleSubmit() async {
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

  // Define regular expression pattern for UPI ID
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

  // Handle submission logic here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Stack(
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
                        '₹$_balance',
                        style: TextStyle(
                            fontSize: 24,
                            color: ThemeService.textColor,
                            fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {},
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
                          fontSize: 16,
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
                          fontSize: 22,
                          color: ThemeService.textColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.swap_vert,
                        color: ThemeService.placeHolder, size: 26),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 0, // replace with actual transaction count
                    itemBuilder: (context, index) {
                      // replace with actual transaction data
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        margin: EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UPI Id: '), // replace with actual data
                            Text('Amount: '), // replace with actual data
                            Text('Requested on: '), // replace with actual data
                            Text(
                              'Approved on: ', // replace with actual data
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              color: ThemeService.third,
                              child: Text(''), // replace with actual status
                            ),
                          ],
                        ),
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
        ],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
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
                      Text(
                        'Please enter your UPI Id',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'sam.wilson@upi',
                          errorText: _textError.isNotEmpty ? _textError : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      CheckboxListTile(
                        value: _isChecked1,
                        onChanged: (bool? value) {
                          _toggleCheckbox1();
                        },
                        title: Text(
                          'I accept this is a valid UPI Id',
                          style: TextStyle(color: _checkColor1),
                        ),
                      ),
                      CheckboxListTile(
                        value: _isChecked2,
                        onChanged: (bool? value) {
                          _toggleCheckbox2();
                        },
                        title: Text(
                          'Save this UPI Id for Future Withdrawals',
                          style: TextStyle(color: _checkColor2),
                        ),
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
