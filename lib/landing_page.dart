import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Selamat Datang di Delivery Order Apps',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        //   Text(
        //     'Apps ini dibuat untuk Technical Test: Mobile Programmer',
        //     textAlign: TextAlign.center,
        //   ),
        //   SizedBox(height: 20),
        //   Text(
        //     'Created By : suryoatm@gmail.com',
        //     textAlign: TextAlign.center,
        //   ),
        ],
      ),
    );
  }
}
