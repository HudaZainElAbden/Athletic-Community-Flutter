import 'dart:io';

import 'package:athletic_community/Pages/AvailableClubs.dart';
import 'package:athletic_community/Services/Auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  double? scHeight;
  double? scWidth;
  Auth _auth = new Auth();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _rememberMeBool = false;

  late SharedPreferences _preferences;
  saveData() async {
    _preferences = await SharedPreferences.getInstance();
    _preferences.setStringList('currentAccount', [_emailController.text, _passwordController.text]);
  }

  getData()async{
    _preferences = await SharedPreferences.getInstance();
    List accountData = _preferences.get('currentAccount') as List;
    if(accountData.isNotEmpty){
      setState(() {
        _emailController.text = accountData[0];
        _passwordController.text = accountData[1];
        _rememberMeBool = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    scHeight = MediaQuery.of(context).size.height;
    scWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      //resizeToAvoidBottomInset : false,//To prevent keyboard moving up an another widget in a stack
        body:
        SingleChildScrollView(
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
        )
    );
  }

  Widget userData(){
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  emailTextFormField(),
                  SizedBox(height: scHeight! / 20,),
                  passwordTextFormField(),
                ],
              ),
            ),
            SizedBox(height: 20,),

            rememberMe(),
            SizedBox(height: 20,),

            loginButton(),
            SizedBox(height: 20,),

            doNotHaveAnAccount(),
          ],
        ),
      ),
    );
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

  Widget emailTextFormField(){
    return Container(
      width: scWidth! * 0.8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),),
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

  Widget passwordTextFormField(){
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
          },
        ),
      ),
    );
  }

  Widget rememberMe(){
    return Padding(
      padding: EdgeInsets.only(left: scWidth! * 0.35),
      child: ListTile(
          title: Row(
            children: [
              Theme(
                data: ThemeData(unselectedWidgetColor: Colors.black87),
                child: Checkbox(
                    activeColor: Colors.black87,
                    value: _rememberMeBool,
                    onChanged: (val) {
                      setState(() {
                        _rememberMeBool = val as bool;
                      });
                    }
                ),
              ),
              Text("Remember Me", style: TextStyle(color: Colors.black87),),
            ],
          )),
    );
  }

  Widget loginButton(){
    return Container(
      alignment: Alignment.center,
      width: scWidth!*0.3,
      height: scHeight!*0.05,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
      child: GestureDetector(
        onTap: ()async{
          if(_formKey.currentState!.validate())
          {
            await _auth.signIn(_emailController.text, _passwordController.text).then((value) async {
              if(value==true){
                if(_rememberMeBool)
                  await saveData();

                else if(!_rememberMeBool)
                  await _preferences.clear();

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome Back <3")));
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AvailableClubs()), (route)=>false);
              }

              else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid information, Please try again...')));
              }
            });
          }
        },
        child: Text("Login", style: GoogleFonts.arsenal(
            textStyle: TextStyle(color: Colors.white, fontSize: 25)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget doNotHaveAnAccount(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have account?", style: TextStyle(fontSize: 15, color: Colors.black87),),

        InkWell(
          onTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Register()));
          },
          child: Text('Create one', style: TextStyle(fontSize: 15, color: Colors.black87, decoration: TextDecoration.underline)),
        )
      ],
    );
  }

}
