import 'dart:io';

import 'package:athletic_community/FirebaseStorage/ImageItem.dart';
import 'package:athletic_community/Services/Auth.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:athletic_community/UIHelp/MyAppBar.dart';
import 'package:athletic_community/UIHelp/SideMenuDrawer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  var imageFile;
  final _picker = ImagePicker();
  PickedFile? image;

  Database _db = new Database();
  Auth _auth = new Auth();
  final _formKey = GlobalKey<FormState>();
  late double scWidth;
  late double scHeight;
  late String _username;
  late String _userMobile;
  late String _userAge;
  late String _userPass;
  TextEditingController _newMobileController = TextEditingController();
  TextEditingController _newUsernameController = TextEditingController();
  TextEditingController _oldUserPassController = TextEditingController();
  TextEditingController _newUserPassController = TextEditingController();
  TextEditingController _confirmNewUserPassController = TextEditingController();

  getImage()async{
    await Permission.photos.request();
    var status = await Permission.photos.status;

    if(status.isGranted){
      image =await _picker.getImage(source: ImageSource.gallery);
      imageFile = File(image!.path);
      setState(() {});
    }
    else{
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Not Accepted')));
    }
  }

  uploadImage()async{
    final _firebaseStorage = FirebaseStorage.instance;
    if(image != null){
      await _firebaseStorage.ref('Images/${UserData.email}').putFile(imageFile).whenComplete((){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded Successfully')));
        setState(() {
          UserData.profileImageBytes = null; //to put the new image
        });
      });
    }
  }

  String? _ageSelected;
  late List<String> ageList = [];
  setAgesList() {
    for (int i = 15; i <= 60; i++) {
      ageList.add(i.toString());
    }
  }

  Stream? accountInfo;
  getAccountInfo() {
    _db.getAccountInfo().then((value) {
      setState(() {
        accountInfo = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAccountInfo();
    setAgesList();
  }

  Widget setEditIcon() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
      child: Icon(
        Icons.edit,
        color: Colors.white,
      ),
    );
  }

  //Of alert dialog
  Widget setSaveAndCancelButtons(String _text){
    return Text(
      "$_text",
      style: TextStyle(
          fontSize: 20,
          color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    scWidth = MediaQuery.of(context).size.width;
    scHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white70,
      drawer: SideMenuDrawer(),
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Container(
          width: scWidth,
          height: scHeight,
          decoration: BoxDecoration(
              // gradient: LinearGradient(colors: [
              //   Colors.white,
              //   Colors.green,
              //   Colors.white,
              // ], begin: Alignment.bottomLeft, end: Alignment.topRight)
              color: Colors.white
          ),

          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder(
              stream: accountInfo,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError)
                    return Text('Error!');
                  else if (snapshot.hasData == false)
                    return Text('Empty Data');
                  else {
                    var _accountMap = snapshot.data;
                    _username = _accountMap['username'];
                    _userMobile = _accountMap['mobile'];
                    _userAge = _accountMap['age'];
                    _userPass = _accountMap['password'];
                    return Column(
                      children: [
                        //profile pic
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black87,
                              radius: scWidth * 0.2,
                              child:
                              UserData.profileImageBytes != null? CircleAvatar(radius: scWidth * 0.2,
                                backgroundImage: Image.memory(UserData.profileImageBytes!, fit: BoxFit.fill,).image,):
                              ImageItem(scWidth*0.4, scWidth * 0.2, UserData.email)
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  //Go to Gallery
                                  await getImage();
                                  if(imageFile != null)
                                    await uploadImage();
                                  setState(() {});
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.black87,
                                      shape: BoxShape.circle),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: scHeight / 20,),

                        //username
                        Row(
                          children: [
                            Text(
                              'Name: ',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text('$_username',
                                style:
                                    TextStyle(color: Colors.black87, fontSize: 20)),
                            GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text('Edit your name:'),
                                          content: Form(
                                            key: _formKey,
                                            child: Container(
                                                width: scWidth * 0.8,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black87),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: TextFormField(
                                                  controller:
                                                      _newUsernameController,
                                                  decoration: InputDecoration(
                                                      hintText: 'New name',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(
                                                        Icons
                                                            .account_circle_outlined,
                                                        color: Colors.black87,
                                                      ),
                                                      hintStyle: TextStyle(
                                                          color: Colors.black87)),
                                                  style: TextStyle(
                                                      color: Colors.black87),
                                                  validator: (val) {
                                                    if (val!.isEmpty)
                                                      return "Please enter your new name";
                                                  },
                                                )),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: scWidth * 0.2,
                                                  height: scHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                    color: Colors.black87,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          _username =
                                                              _newUsernameController
                                                                  .text;
                                                          _db.updateAccount(
                                                              _username,
                                                              _userMobile,
                                                              _userAge,
                                                              _userPass);
                                                          _newUsernameController
                                                              .text = "";
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    child: setSaveAndCancelButtons('Save')
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: scWidth * 0.2,
                                                  height: scHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                    color: Colors.black87,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      Navigator.of(context).pop();
                                                      _newUsernameController
                                                          .text = "";
                                                    },
                                                    child: setSaveAndCancelButtons('Cancel')
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: setEditIcon(),
                                ))
                          ],
                        ),
                        SizedBox(height: scHeight / 20,),

                        //mobile
                        Row(
                          children: [
                            Text('Mobile: ',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text('$_userMobile',
                                style:
                                    TextStyle(color: Colors.black87, fontSize: 20)),
                            GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text('Edit Mobile:'),
                                          content: Form(
                                            key: _formKey,
                                            child: Container(
                                                width: scWidth * 0.8,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black87),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: TextFormField(
                                                  controller:
                                                      _newMobileController,
                                                  decoration: InputDecoration(
                                                      hintText: 'New Mobile',
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(
                                                        Icons.phone_android,
                                                        color: Colors.black87,
                                                      ),
                                                      hintStyle: TextStyle(
                                                          color: Colors.black87)),
                                                  style: TextStyle(
                                                      color: Colors.black87),
                                                  validator: (val) {
                                                    bool isMobileCorrect = true;
                                                    if (val!.length != 11)
                                                      isMobileCorrect = false;

                                                    if (int.tryParse(val) ==
                                                        null) //to check if mobile consists of only int numbers or not
                                                      isMobileCorrect = false;

                                                    if (val.isEmpty)
                                                      return "Please enter your mobile";
                                                    else if (isMobileCorrect ==
                                                        false)
                                                      return "Incorrect mobile number";
                                                  },
                                                )),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: scWidth * 0.2,
                                                  height: scHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                    color: Colors.black87,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          _userMobile =
                                                              _newMobileController
                                                                  .text;
                                                          _db.updateAccount(
                                                              _username,
                                                              _userMobile,
                                                              _userAge,
                                                              _userPass);
                                                          _newMobileController
                                                              .text = "";
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    child: setSaveAndCancelButtons('Save')
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: scWidth * 0.2,
                                                  height: scHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                    color: Colors.black87,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      Navigator.of(context).pop();
                                                      _newMobileController.text =
                                                          "";
                                                    },
                                                    child: setSaveAndCancelButtons('Cancel')
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: setEditIcon(),
                                ))
                          ],
                        ),
                        SizedBox(height: scHeight / 20,),

                        //age
                        Row(
                          children: [
                            Text('Age: ',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text('$_userAge',
                                style:
                                    TextStyle(color: Colors.black87, fontSize: 20)),
                            GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        //used StatefulBuilder to change value with setState inside the alert dialog
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: Text('Edit your age:'),
                                            content: Container(
                                              alignment: Alignment.center,
                                              width: scWidth * 0.6,
                                              height: scHeight / 20,
                                              child: DropdownButton(
                                                dropdownColor: Colors.grey[500]!
                                                    .withOpacity(0.9),
                                                hint: Text(
                                                  '$_userAge',
                                                ),
                                                value: _ageSelected,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    _ageSelected =
                                                        newValue as String;
                                                  });
                                                },
                                                items: ageList.map((valueItem) {
                                                  return DropdownMenuItem(
                                                      value: valueItem,
                                                      child: Text(
                                                        valueItem,
                                                      ));
                                                }).toList(),
                                              ),
                                            ),
                                            actions: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceAround,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: scWidth * 0.2,
                                                    height: scHeight * 0.05,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              22),
                                                      color: Colors.black87,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        setState(() {
                                                          _userAge =
                                                              _ageSelected!;
                                                          _db.updateAccount(
                                                              _username,
                                                              _userMobile,
                                                              _userAge,
                                                              _userPass);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: setSaveAndCancelButtons('Save'),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: scWidth * 0.2,
                                                    height: scHeight * 0.05,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              22),
                                                      color: Colors.black87,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          _ageSelected = _userAge;
                                                        });
                                                      },
                                                      child: setSaveAndCancelButtons('Cancel'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        });
                                      }).then((value) {
                                    setState(
                                        () {}); //to refresh outside alert dialog
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: setEditIcon(),
                                ))
                          ],
                        ),
                        SizedBox(height: scHeight / 20,),

                        //password
                        Row(
                          children: [
                            Text('Password',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text('Edit your password:'),
                                          content: Form(
                                              key: _formKey,
                                              child: Container(
                                                height: scHeight * 0.4,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      //old pass
                                                      Container(
                                                          width: scWidth * 0.8,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black87),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                          child: TextFormField(
                                                            controller:
                                                                _oldUserPassController,
                                                            obscureText: true,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Old password',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons.lock,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .black87)),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87),
                                                            validator: (val) {
                                                              if (val!.isEmpty)
                                                                return "Please enter your old password";
                                                              else if (val !=
                                                                  _userPass)
                                                                return "Wrong password!";
                                                            },
                                                          )),
                                                      SizedBox(
                                                        height: scHeight / 20,
                                                      ),
                                                      //new pass
                                                      Container(
                                                          width: scWidth * 0.8,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black87),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                          child: TextFormField(
                                                            controller:
                                                                _newUserPassController,
                                                            obscureText: true,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'New password',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons.lock,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .black87)),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87),
                                                            validator: (val) {
                                                              if (val!.isEmpty)
                                                                return "Please enter your new password";
                                                              else if (val
                                                                      .length <
                                                                  6)
                                                                return 'Password mut be more than 5 characters...';
                                                            },
                                                          )),
                                                      SizedBox(
                                                        height: scHeight / 20,
                                                      ),
                                                      //confirm new pass
                                                      Container(
                                                          width: scWidth * 0.8,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black87),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                          child: TextFormField(
                                                            controller:
                                                                _confirmNewUserPassController,
                                                            obscureText: true,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Confirm new password',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    prefixIcon:
                                                                        Icon(
                                                                      Icons.lock,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .black87)),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black87),
                                                            validator: (val) {
                                                              if (val!.isEmpty)
                                                                return "Please enter your new password again";
                                                              else if (val !=
                                                                  _newUserPassController
                                                                      .text)
                                                                return "Password Confirmation is wrong";
                                                            },
                                                          )),
                                                      SizedBox(
                                                        height: scHeight / 20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: scWidth * 0.2,
                                                  height: scHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                    color: Colors.black87,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          _userPass =
                                                              _newUserPassController
                                                                  .text;
                                                          _auth.resetPassword(
                                                              _userPass);
                                                          _db.updateAccount(
                                                              _username,
                                                              _userMobile,
                                                              _userAge,
                                                              _userPass);
                                                          _oldUserPassController
                                                              .text = "";
                                                          _newUserPassController
                                                              .text = "";
                                                          _confirmNewUserPassController
                                                              .text = "";
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    child: setSaveAndCancelButtons('Save'),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: scWidth * 0.2,
                                                  height: scHeight * 0.05,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(22),
                                                    color: Colors.black87,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      Navigator.of(context).pop();
                                                      _oldUserPassController
                                                          .text = "";
                                                      _newUserPassController
                                                          .text = "";
                                                      _confirmNewUserPassController
                                                          .text = "";
                                                    },
                                                    child: setSaveAndCancelButtons('Cancel'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: setEditIcon(),
                                ))
                          ],
                        )
                      ],
                    );
                  }
                } else {
                  return Text('Error');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
