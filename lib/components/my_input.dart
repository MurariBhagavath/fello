import 'package:flutter/material.dart';

class MyInput extends StatelessWidget {
  const MyInput(
      {super.key,
      required this.controller,
      required this.title,
      this.secure,
      required this.validate});

  final TextEditingController controller;
  final String title;
  final String? Function(String?)? validate;
  final bool? secure;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: TextFormField(
        validator: validate,
        controller: controller,
        obscureText: secure ?? false,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 12),
          border: InputBorder.none,
          hintText: title,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
        cursorColor: Colors.black,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
