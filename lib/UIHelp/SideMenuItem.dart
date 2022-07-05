import 'package:athletic_community/Pages/About.dart';
import 'package:athletic_community/Pages/AvailableClubs.dart';
import 'package:athletic_community/Pages/Login.dart';
import 'package:athletic_community/Pages/MyAccount.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:flutter/material.dart';

class SideMenuItem extends StatefulWidget {
  String? _text;
  IconData? _icon;
  SideMenuItem(this._text, this._icon);

  @override
  _SideMenuItemState createState() => _SideMenuItemState();
}

class _SideMenuItemState extends State<SideMenuItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(widget._text == 'Home')
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> AvailableClubs()), (route)=>false);

        else if(widget._text == 'My Account')
            Navigator.push(context, MaterialPageRoute(builder: (context)=> MyAccount()));

        else if(widget._text == 'About')
              Navigator.push(context, MaterialPageRoute(builder: (context)=> About()));


        else if(widget._text == 'Logout'){
          UserData.profileImageBytes = null;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Login()), (route)=>false);
        }

      },
      child: Container(
        child: Row(
          children: [
            Icon(widget._icon, size: 35,),
            Text('${widget._text}', style: TextStyle(fontSize: 25, color: Colors.black87),)
          ],
        ),
      ),
    );
  }
}
