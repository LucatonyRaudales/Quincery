import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class MyButton extends StatelessWidget {
  RoundedLoadingButtonController buttonController;
  void Function() onPressed;
  MyButton({this.buttonController, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      color: Colors.blueGrey,
      child: Text('Guardar', style: TextStyle(color: Colors.white)),
      controller: buttonController,
      onPressed: onPressed,
    );
  }
}
