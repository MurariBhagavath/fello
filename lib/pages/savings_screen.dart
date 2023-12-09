// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:fello/components/goal_card.dart';
import 'package:fello/components/my_button.dart';
import 'package:fello/components/my_input.dart';
import 'package:fello/constants.dart';
import 'package:fello/pages/create_goal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  int _index = 0;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _payController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final categories = [
    'Personal',
    'Gadget',
    'Travel',
    'Investment',
    'Health',
    'House',
    'Education'
  ];

  void payAmount(String uid) async {
    if (_formKey.currentState!.validate()) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('goals')
          .doc(uid)
          .update({
        'paid': FieldValue.increment(int.parse(_payController.text.trim())),
      });
      _payController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 25,
              child: Text(
                'Savings',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            Positioned(
              top: 25,
              right: 25,
              child: IconButton(
                  onPressed: () async {
                    await _auth.signOut();
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                  )),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: width,
                height: height * 0.5,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              child: Container(
                width: width,
                height: height * 0.7,
                child: StreamBuilder(
                  stream: _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .collection('goals')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isEmpty) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          child: GoalCard(
                            height: height,
                            width: width,
                            child: Center(
                              child: Text(
                                'No Goals',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      } else {
                        var goalsData = snapshot.data!.docs;

                        return PageView.builder(
                          itemCount: snapshot.data!.docs.length,
                          controller: PageController(viewportFraction: 0.75),
                          onPageChanged: (index) =>
                              setState(() => _index = index),
                          itemBuilder: (context, index) {
                            final ValueNotifier<double> _valueNotifier =
                                ValueNotifier(0);
                            final total = goalsData[_index].data()['amount'];
                            final paid = goalsData[_index].data()['paid'];
                            var category = goalsData[_index].data()['category'];
                            if (!categories.contains(category)) {
                              category = 'other';
                            }
                            return AnimatedPadding(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastOutSlowIn,
                              padding:
                                  EdgeInsets.all(_index == index ? 0.0 : 8.0),
                              child: GoalCard(
                                height: height,
                                width: width,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Image.asset(
                                        'assets/images/${category}.png',
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                    Text(
                                      goalsData[_index].data()['title'],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 12),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 48),
                                      child:
                                          DashedCircularProgressBar.aspectRatio(
                                        aspectRatio: 1, // width ÷ height
                                        valueNotifier: _valueNotifier,
                                        progress: (paid / total) * 100,
                                        startAngle: 225,
                                        sweepAngle: 270,
                                        foregroundColor: secondaryColor,
                                        backgroundColor:
                                            const Color(0xffeeeeee),
                                        foregroundStrokeWidth: 12,
                                        backgroundStrokeWidth: 12,
                                        animation: true,
                                        seekSize: 6,
                                        seekColor: const Color(0xffeeeeee),
                                        child: Center(
                                          child: ValueListenableBuilder(
                                              valueListenable: _valueNotifier,
                                              builder: (_, double value, __) =>
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '${value.toInt()}%',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 48,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 24),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Remain',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            '₹' + (total - paid).toString(),
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: Divider(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 24),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            '₹' + total.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Scaffold.of(context).showBottomSheet(
                                            backgroundColor: Colors.redAccent,
                                            (context) => Container(
                                              width: width,
                                              child: Form(
                                                key: _formKey,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16.0),
                                                      child: Text(
                                                        'Pay amount',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 24.0,
                                                          horizontal: 16),
                                                      child: MyInput(
                                                          controller:
                                                              _payController,
                                                          title:
                                                              'Enter pay amount',
                                                          validate: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please enter amount';
                                                            }
                                                            return null;
                                                          }),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      child: AnimatedButton(
                                                        isReverse: true,
                                                        selectedTextColor:
                                                            Colors.black,
                                                        transitionType:
                                                            TransitionType
                                                                .CENTER_ROUNDER,
                                                        text: 'pay',
                                                        onPress: () =>
                                                            payAmount(goalsData[
                                                                        _index]
                                                                    .data()[
                                                                'goalId']),
                                                      ),
                                                    ),
                                                    SizedBox(height: 24),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            enableDrag: true,
                                          );
                                        },
                                        child: Text(
                                          'Pay',
                                          style: TextStyle(color: darkBlue),
                                        )),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return GoalCard(
                        height: height,
                        width: width,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return GoalCard(
                        height: height,
                        width: width,
                        child: Text(''),
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              child: AnimatedButton(
                backgroundColor: redColor,
                width: width * 0.8,
                isReverse: true,
                selectedTextColor: Colors.black,
                transitionType: TransitionType.CENTER_ROUNDER,
                text: 'Create Goal',
                onPress: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateGoalScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
