import 'package:athletic_community/FirebaseStorage/ImageItem.dart';
import 'package:athletic_community/Pages/AvailableSports.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:athletic_community/UIHelp/MyAppBar.dart';
import 'package:athletic_community/UIHelp/SideMenuDrawer.dart';
import 'package:flutter/material.dart';

class AvailableClubs extends StatefulWidget {
  @override
  _AvailableClubsState createState() => _AvailableClubsState();
}

class _AvailableClubsState extends State<AvailableClubs> {
  Database _db = new Database();
  late double scWidth;
  late double scHeight;

  Stream? clubsStream;
  getClubsName(){
    _db.getClubsNames().then((value){
      setState(() {
        clubsStream = value;
      });
    });
  }

  getUserInfo()async{
    _db.getUserInfo().then((value){
      Map _accountMap = value.data();

      setState(() {
        UserData.username = _accountMap['username'];
        UserData.punishmentDate = _accountMap['punishmentDate'];
      });

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClubsName();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    scWidth = MediaQuery.of(context).size.width;
    scHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white70,
      drawer: SideMenuDrawer(),
      appBar: MyAppBar(),
      body: Container(
        width: scWidth,
        height: scHeight,
         decoration: BoxDecoration(
        //     gradient: LinearGradient(colors: [
        //       Colors.white,
        //       Colors.green,
        //       Colors.white,
        //     ], begin: Alignment.bottomLeft, end: Alignment.topRight)
        color: Colors.white
        ),

        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              //Available Clubs
              Text('Available Clubs:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20)),
              SizedBox(height: scHeight/20,),
              StreamBuilder(
                stream: clubsStream,
                builder: (context, AsyncSnapshot snap){
                  if(snap.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else if(snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.done){
                    if (snap.hasError)
                      return Text('Error!', style: TextStyle(color: Colors.white),);
                    else if (snap.hasData == false)
                      return Text('Empty Data', style: TextStyle(color: Colors.white));
                    else{
                      return Expanded(
                        child: ListView.separated(
                            itemCount: snap.data.docs.length,
                            itemBuilder: (BuildContext context, int index){
                              Map _clubMap = snap.data.docs[index].data();

                              return clubIcon(_clubMap['clubName']);
                        }, separatorBuilder: (BuildContext context, int index)=>Divider()),
                      );
                    }
                  }
                  else
                    return Text('Error!', style: TextStyle(color: Colors.white));
                },
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget clubIcon(String _clubName){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>AvailableSports('$_clubName')));
      },
      child: Container(
        height: scHeight/8,
        width: scWidth * 0.9,
        decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ImageItem(scWidth * 0.4, scWidth * 0.1, _clubName),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text('$_clubName', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
