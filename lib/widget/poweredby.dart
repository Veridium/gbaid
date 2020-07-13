import 'package:flutter/material.dart';

class PoweredByLogo extends StatelessWidget {
  PoweredByLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("powered by"),
        Image.asset('images/veridium_tagline_Color.png',
            width: 100.0, height: 100.0),
      ],
    );
  }
}
