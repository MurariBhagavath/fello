import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fello/components/my_button.dart';
import 'package:fello/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void authenticateUser() async {
    var user = await _firestore
        .collection('users')
        .where('email', isEqualTo: _emailController.text.trim())
        .get();
    if (user.docs.isEmpty) {
      var flag = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      await _firestore.collection('users').doc(flag.user!.uid).set({
        "uid": flag.user!.uid,
        "email": _emailController.text.trim(),
      });
    } else {
      await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: 'Email'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(hintText: 'Password'),
          ),
          SizedBox(height: 10),
          MyButton(
              width: width,
              onTap: authenticateUser,
              title: 'Login',
              color: redColor)
        ],
      ),
    );
  }
}
