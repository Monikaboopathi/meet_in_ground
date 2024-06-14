import 'package:flutter/material.dart';

import 'package:meet_in_ground/constant/themes_service.dart';

class TermsandCondition extends StatelessWidget {
  const TermsandCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
          backgroundColor: ThemeService.background,
          notificationPredicate: (notification) => false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ThemeService.textColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Terms & Condition",
            style: TextStyle(color: ThemeService.textColor),
          )),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Meet In Ground - Refer & Earn (Terms & Conditions)",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildNumberedText(1,
                        "Users will earn Rs. 10 for each successful referral made through their unique referral link."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(2,
                        "A successful referral is defined as a new user who signs up on the Meet In Ground app using the referral link and completes their account registration."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(3,
                        "The referral reward of Rs. 10 will be credited to the user's account once the referred user completes their registration successfully."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(
                        4, "Users can accumulate referral earnings over time."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(5,
                        "There is 3 limit to the number of referrals a user can make."),
                  ],
                ),
              ),
              Divider(
                color: ThemeService.transparent,
              ),
              Text(
                "Meet In Ground - Wallet  (Terms & Conditions)",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildNumberedText(1,
                        "Users must have a minimum wallet balance of Rs. 50 to be eligible for withdrawal."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(2,
                        "Only registered and verified users are eligible to initiate wallet withdrawals.To initiate a withdrawal, users must navigate to the Wallet in Meet In Ground App."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(3,
                        "Users will be prompted to provide their UPI ID for withdrawal.Withdrawal requests will be processed within 24 working days."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(4,
                        "The withdrawal process may involve verification steps to ensure the security and legitimacy of the transaction.Users must provide accurate and valid UPI ID information to receive the withdrawn amount."),
                    SizedBox(
                      height: 10,
                    ),
                    buildNumberedText(5,
                        "The UPI ID entered during the withdrawal process must be linked to the user's bank account."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNumberedText(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeService.third),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            width: 250,
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: ThemeService.textColor),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}
