import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fello/components/my_button.dart';
import 'package:fello/components/my_input.dart';
import 'package:fello/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:uuid/uuid.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _durationController = TextEditingController();

  final amounts = [10000, 25000, 50000];
  int _amount = -1;

  final categories = [
    'Personal',
    'Gadget',
    'Travel',
    'Investment',
    'Health',
    'House',
    'Education'
  ];
  int _category = -1;

  final _formKey = GlobalKey<FormState>();

  final uuid = new Uuid();

  void createGoal() async {
    if (_formKey.currentState!.validate()) {
      var docId = uuid.v1();
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('goals')
          .doc(docId)
          .set({
        'title': _titleController.text.trim(),
        'category': _categoryController.text.trim(),
        'amount': int.parse(_amountController.text.trim()),
        'duration': int.parse(_durationController.text.trim()),
        'timestamp': DateTime.now(),
        'paid': 0,
        'goalId': docId,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Create a Goal'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                MyInput(
                  title: 'Enter title here',
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                  controller: _titleController,
                ),
                SizedBox(height: 24),
                Text(
                  'Amount',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                MyInput(
                  title: 'Enter amount here',
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Amount';
                    }
                    return null;
                  },
                  controller: _amountController,
                ),
                SizedBox(height: 4),
                Wrap(
                  children: List.generate(
                    amounts.length,
                    (index) => ChoiceChip(
                      label: Text('₹' + amounts[index].toString()),
                      selected: _amount == index,
                      onSelected: (bool selected) {
                        setState(() {
                          _amount = selected ? index : -1;
                          if (_amount >= 0) {
                            _amountController.value = _amountController.value
                                .copyWith(
                                    text: amounts[_amount!].toString(),
                                    selection: TextSelection.collapsed(
                                        offset: amounts[_amount!]
                                            .toString()
                                            .length));
                          } else {
                            _amountController.value = _amountController.value
                                .copyWith(
                                    text: ''.toString(),
                                    selection: TextSelection.collapsed(
                                        offset: ''.toString().length));
                          }
                        });
                      },
                      showCheckmark: false,
                      selectedColor: redColor,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Category',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                MyInput(
                  title: 'Enter category here',
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Category';
                    }
                    return null;
                  },
                  controller: _categoryController,
                ),
                SizedBox(height: 4),
                Wrap(
                  children: List.generate(
                    categories.length,
                    (index) => ChoiceChip(
                      label: Text('₹' + categories[index].toString()),
                      selected: _category == index,
                      onSelected: (bool selected) {
                        setState(() {
                          _category = selected ? index : -1;
                          if (_category >= 0) {
                            _categoryController.value =
                                _categoryController.value.copyWith(
                                    text: categories[_category!].toString(),
                                    selection: TextSelection.collapsed(
                                        offset: categories[_category!]
                                            .toString()
                                            .length));
                          } else {
                            _categoryController.value =
                                _categoryController.value.copyWith(
                                    text: ''.toString(),
                                    selection: TextSelection.collapsed(
                                        offset: ''.toString().length));
                          }
                        });
                      },
                      showCheckmark: false,
                      selectedColor: redColor,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Duration',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                MyInput(
                  title: 'Enter Duration here (in months)',
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Duration';
                    }
                    return null;
                  },
                  controller: _durationController,
                ),
                Spacer(),
                AnimatedButton(
                  text: 'Create Goal',
                  onPress: createGoal,
                  transitionType: TransitionType.BOTTOM_CENTER_ROUNDER,
                  backgroundColor: redColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
