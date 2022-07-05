import 'package:athletic_community/FirebaseStorage/ImageItem.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SideMenuItem.dart';

class SideMenuDrawer extends StatefulWidget {
  const SideMenuDrawer({Key? key}) : super(key: key);

  @override
  _SideMenuDrawerState createState() => _SideMenuDrawerState();
}

class _SideMenuDrawerState extends State<SideMenuDrawer> {
  Database _db = new Database();

  Stream? accountInfo;
  getAccountInfo(){
    _db.getAccountInfo().then((value){
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
  }

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    return Drawer(

      child: Container(
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //     colors: [
            //       Colors.white,
            //       Colors.green,
            //       Colors.white
            //     ],
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight
            // )
          color: Colors.blue
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                StreamBuilder(
                  stream: accountInfo,
                  builder: (context, AsyncSnapshot snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting)
                      return CircularProgressIndicator();
                    else if(snapshot.connectionState == ConnectionState.done || snapshot.connectionState == ConnectionState.active){
                      if(snapshot.hasError)
                        return Text('Error!');
                      else if(snapshot.hasData == false)
                        return Text('Empty Data!');
                      else{
                        var _accountMap = snapshot.data;
                        //profile pic
                        return Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black87,
                                radius: scWidth*0.1,
                                child:
                                UserData.profileImageBytes != null? CircleAvatar(radius: scWidth * 0.2,
                                  backgroundImage: Image.memory(UserData.profileImageBytes!, fit: BoxFit.fill,).image,):
                                ImageItem(scWidth*0.2, scWidth * 0.2, UserData.email)

                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text('${_accountMap['username']}', style: GoogleFonts.arsenal(
                                  textStyle:
                                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20),
                                ),),
                              )
                            ],
                          );
                      }
                    }
                    else
                      return Text('Error!');
                  },
                ),

                SizedBox(height: 30,),
                SideMenuItem('Home', Icons.home),
                SizedBox(height: 30,),
                SideMenuItem('My Account', Icons.account_circle_outlined),
                SizedBox(height: 30,),
                SideMenuItem('About', Icons.help),
                SizedBox(height: 30,),
                SideMenuItem('Logout', Icons.logout),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
