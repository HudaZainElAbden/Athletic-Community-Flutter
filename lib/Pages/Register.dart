import 'package:athletic_community/Models/Account.dart';
import 'package:athletic_community/Pages/Login.dart';
import 'package:athletic_community/Services/Auth.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AvailableClubs.dart';


class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  double? scHeight;
  double? scWidth;
  Auth _auth = new Auth();
  Database _db = new Database();

  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  int _genderGroupValue = 0;
  String? _ageSelected;
  late List<String> ageList = [];

  setAgesList(){
    for(int i=15; i<=60; i++)
    {
      ageList.add(i.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setAgesList();
  }

  @override
  Widget build(BuildContext context) {
    scHeight = MediaQuery.of(context).size.height;
    scWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      //resizeToAvoidBottomInset : false,//To prevent keyboard moving up an another widget in a stack
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
                color: Colors.blue
            ),

            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      appIcon(),
                      appTitle()
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)
                        )
                    ),
                    child: userData(),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget appIcon(){
    return Padding(
      padding: const EdgeInsets.only(top: 70.0),
      child: Hero(
        tag: 'apps_icon',
        child: Image(
            width: scWidth! * 0.2,
            image: AssetImage('assets/images/appIcon.png')
        ),
      ),
    );
  }

  Widget appTitle(){
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        'Welcome to Athletic Community',
        style: GoogleFonts.arsenal(
          textStyle: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget userData(){
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //username
                    usernameTextFormField(),
                    SizedBox(height: scHeight! / 20,),
                    //mobile
                    mobileTextFormField(),
                    SizedBox(height: scHeight! / 20,),

                    emailTextFormField(),
                    SizedBox(height: scHeight! / 20,),
                    //password
                    passTextFormField(),
                    SizedBox(height: scHeight! / 20,),
                    //confirm password
                    confirmPassTextFormField(),
                    SizedBox(height: scHeight! / 20,),
                  ],
                ),
              ),
              //age list
              ageDropdownButton(),
              //gender radio buttons
              genderRadioButtons(),
              SizedBox(height: scHeight! / 20,),

              SizedBox(height: 20,),

              //register button
              registerButton(),
              SizedBox(height: 20,),
              //already have one
              alreadyHaveAccount()
            ],
          ),
        ),
      ),
    );
  }

  Widget usernameTextFormField(){
    return Container(
      width: scWidth! * 0.8,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
              hintText: 'Username',
              //border: InputBorder.none,
              prefixIcon: Icon(
                Icons.account_circle_outlined,
                color: Colors.black87,
              ),
              hintStyle: TextStyle(color: Colors.black87)),
          style: TextStyle(color: Colors.black87),
          validator: (val) {
            if (val!.isEmpty)
              return "Please enter your username";
          },
        ),
      ),
    );
  }

  Widget mobileTextFormField(){
    return Container(
      width: scWidth! * 0.8,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextFormField(
          controller: _mobileController,
          decoration: InputDecoration(
              hintText: 'Mobile',
              //border: InputBorder.none,
              prefixIcon: Icon(
                Icons.phone_android,
                color: Colors.black87,
              ),
              hintStyle: TextStyle(color: Colors.black87)),
          style: TextStyle(color: Colors.black87),
          validator: (val) {
            bool isMobileCorrect = true;
            if(val!.length != 11)
              isMobileCorrect = false;

            if(int.tryParse(val) == null)//to check if mobile consists of only int numbers or not
              isMobileCorrect = false;

            if (val.isEmpty)
              return "Please enter your mobile";
            else if(isMobileCorrect == false)
              return "Incorrect mobile number";
          },
        ),
      ),
    );
  }

  Widget emailTextFormField(){
    return Container(
      width: scWidth! * 0.8,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
              hintText: 'Email',
              //border: InputBorder.none,
              prefixIcon: Icon(
                Icons.email,
                color: Colors.black87,
              ),
              hintStyle: TextStyle(color: Colors.black87)),
          style: TextStyle(color: Colors.black87),
          validator: (val) {
            if (val!.isEmpty)
              return "Please enter your email";
          },
        ),
      ),
    );
  }

  Widget passTextFormField(){
    return Container(
      width: scWidth! * 0.8,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
              hintText: 'Password',
              //border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black87,
              ),
              hintStyle: TextStyle(color: Colors.black87)),
          style: TextStyle(color: Colors.black87),
          validator: (val) {
            if (val!.isEmpty)
              return "Please enter your password";
            else if(val.length < 6)
              return 'Password must be more than 5 characters...';
          },
        ),
      ),
    );
  }

  Widget confirmPassTextFormField(){
    return Container(
      width: scWidth! * 0.8,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
              hintText: 'Confirm Password',
              //border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black87,
              ),
              hintStyle: TextStyle(color: Colors.black87)),
          style: TextStyle(color: Colors.black87),
          validator: (val) {
            if (val!.isEmpty)
              return "Please enter your password again";
            else if(_passwordController.text != val)
              return "Password Confirmation is wrong";
          },
        ),
      ),
    );
  }

  Widget ageDropdownButton(){
    return DropdownButton(
      dropdownColor: Colors.white.withOpacity(0.9),
      hint: Text('Select Age', style: TextStyle(color: Colors.black87),),
      value: _ageSelected,
      onChanged: (newValue){
        setState(() {
          _ageSelected = newValue as String;
        });
      },
      items: ageList.map((valueItem){
        return DropdownMenuItem(
            value: valueItem,
            child: Text(valueItem, style: TextStyle(color: Colors.black87),)
        );
      }).toList(),

    );
  }

  Widget genderRadioButtons(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            'Gender: ',
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        Expanded(
            child: Row(
              children: [
                Expanded(
                    child: ListTile(
                      title: Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.black87),
                            child: Radio(
                                activeColor: Colors.black87,
                                value: 0,
                                groupValue: _genderGroupValue,
                                onChanged: (val) {
                                  setState(() {
                                    _genderGroupValue = val as int;
                                  });
                                }),
                          ),
                          Text('Male', style: TextStyle(color: Colors.black87),)
                        ],
                      ),
                    )),
                Expanded(
                    child: ListTile(
                      title: Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.black87),
                            child: Radio(
                                activeColor: Colors.black87,
                                value: 1,
                                groupValue: _genderGroupValue,
                                onChanged: (val) {
                                  setState(() {
                                    _genderGroupValue = val as int;
                                  });
                                }),
                          ),
                          Text('Female', style: TextStyle(color: Colors.black87))
                        ],
                      ),
                    ))
              ],
            ))
      ],
    );
  }

  Widget registerButton(){
    return Container(
      alignment: Alignment.center,
      width: scWidth!*0.3,
      height: scHeight!*0.05,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
      child: GestureDetector(
        onTap: ()async{
          if(_formKey.currentState!.validate() && _ageSelected == null)
          {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select your age...")));
          }

          else if(_formKey.currentState!.validate())
          {
            //TODO CREATE TABLES
            await _auth.signUp(_emailController.text, _passwordController.text).then((value){
              if(value == true){
                _db.saveAccount(new Account(_usernameController.text, _emailController.text, _passwordController.text,
                    _genderGroupValue==0?'M':'F', _ageSelected, _mobileController.text, ""));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome to Athletic Community <3")));
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AvailableClubs()), (route)=>false);
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed')));
              }
            });

          }
        },
        child: Text("Register", style: GoogleFonts.arsenal(
            textStyle: TextStyle(color: Colors.white, fontSize: 25)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget alreadyHaveAccount(){
    return InkWell(
      onTap: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
      },
      child: Text('Already have one!', style: TextStyle(fontSize: 15, color: Colors.black87, decoration: TextDecoration.underline)),
    );
  }

}
