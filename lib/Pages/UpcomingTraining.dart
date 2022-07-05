import 'package:athletic_community/Models/BookedTraining.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:athletic_community/UIHelp/MyAppBar.dart';
import 'package:athletic_community/UIHelp/SideMenuDrawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingTraining extends StatefulWidget {

  @override
  _UpcomingTrainingState createState() => _UpcomingTrainingState();
}

class _UpcomingTrainingState extends State<UpcomingTraining> {
  late double scWidth;
  late double scHeight;
  final _formKey = GlobalKey<FormState>();
  Database _db = new Database();

  Stream? reservationTimeStream;
  getReservationTimeList()async{
    _db.getReservationTime().then((value){
      setState(() {
        reservationTimeStream = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReservationTimeList();
  }

  @override
  Widget build(BuildContext context) {
    scWidth = MediaQuery.of(context).size.width;
    scHeight = MediaQuery.of(context).size.height;
    TextEditingController _reservationCodeController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white10,
      drawer: SideMenuDrawer(),
      appBar: MyAppBar(),
      body: Container(
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
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: reservationTimeStream,
            builder: (context, AsyncSnapshot snap){
              if(snap.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator(),);
              else if(snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.done) {
                if (snap.hasError)
                  return Center(
                      child: Text('Error!', style: TextStyle(color: Colors.white),));
                else if (snap.hasData == false)
                  return Center(child: Text('Empty Data', style: TextStyle(color: Colors.white)));
                else{
                  DateTime _now = DateTime.now();
                  String _currentTime = DateFormat('HH:mm').format(_now);
                  String _currentDate = DateFormat('yyyy-MM-dd').format(_now);

                  DateTime punishmentDate = _now.add(new Duration(days: 3));
                  String _punishmentDate = DateFormat('yyyy-MM-dd').format(punishmentDate);

                  List<BookedTraining> _bookedTrainingList = [];

                  for(int i=0; i<snap.data.docs.length; i++){
                    Map _bookedTrainingMap = snap.data.docs[i].data();
                    BookedTraining _currentBookedTraining = new BookedTraining(_bookedTrainingMap['clubName'], _bookedTrainingMap['sportName'],
                        _bookedTrainingMap['date'], _bookedTrainingMap['time'], _bookedTrainingMap['price']);
                    _currentBookedTraining.id = snap.data.docs[i].id;//used as code of this reservation
                    _currentBookedTraining.startTimeMinusOneHour = _bookedTrainingMap['startTimeMinusOneHour'];//used while cancelling reservation time

                    _bookedTrainingList.add(_currentBookedTraining);

                  }

                  return ListView.separated(
                    itemCount: snap.data.docs.length,
                    itemBuilder: (context, index){
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: scWidth*0.9,
                          decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(22)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                //clubName
                                Row(
                                  children: [
                                    Text('Club: ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),),
                                    Text('${_bookedTrainingList[index].clubName} ', style: TextStyle(color: Colors.black87, fontSize: 20),),
                                  ],
                                ),
                                SizedBox(height: scHeight/30,),
                                //sportName
                                Row(
                                  children: [
                                    Text('Sport: ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),),
                                    Text('${_bookedTrainingList[index].sportName} ', style: TextStyle(color: Colors.black87, fontSize: 20),),
                                  ],
                                ),
                                SizedBox(height: scHeight/30,),
                                //date
                                Row(
                                  children: [
                                    Text('Date: ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),),
                                    Text('${_bookedTrainingList[index].date} ', style: TextStyle(color: Colors.black87, fontSize: 20),),
                                  ],
                                ),
                                SizedBox(height: scHeight/30,),
                                //time
                                Row(
                                  children: [
                                    Text('Time Slot: ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),),
                                    Text('${_bookedTrainingList[index].time} ', style: TextStyle(color: Colors.black87, fontSize: 20),),
                                  ],
                                ),
                                SizedBox(height: scHeight/30,),
                                //price
                                Row(
                                  children: [
                                    Text('Price: ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),),
                                    Text('${_bookedTrainingList[index].price} EGP', style: TextStyle(color: Colors.black87, fontSize: 20),),
                                  ],
                                ),
                                SizedBox(height: scHeight/30,),

                                //enter code & cancel buttons
                                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    //code of reservation
                                    Container(
                                      alignment: Alignment.center,
                                      width: scWidth*0.2,
                                      height: scHeight*0.05,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                                      child: GestureDetector(
                                        onTap: ()async{
                                          showDialog(context: context, builder: (context){
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Text('Code of reservation:\n entered by ${_bookedTrainingList[index].clubName} Crew'),

                                              content: Form(
                                                key: _formKey,
                                                child: Container(
                                                  width: scWidth * 0.8,
                                                  decoration: BoxDecoration(border: Border.all(color: Colors.black87), borderRadius: BorderRadius.circular(15)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: TextFormField(
                                                      controller: _reservationCodeController,
                                                      decoration: InputDecoration(
                                                          hintText: 'Reservation code',
                                                          border: InputBorder.none,
                                                          prefixIcon: Icon(
                                                            Icons.code,
                                                            color: Colors.black87,
                                                          ),
                                                          hintStyle: TextStyle(color: Colors.black87)),
                                                      style: TextStyle(color: Colors.black87),
                                                      validator: (val) {
                                                        if (val!.isEmpty)
                                                          return "Please enter reservation code";
                                                        else if(val != _bookedTrainingList[index].id){
                                                          print(_bookedTrainingList[index].id);
                                                          return "Invalid code, please try again...";
                                                        }

                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                //submit button
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: scWidth*0.2,
                                                  height: scHeight*0.05,
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                                                  child: GestureDetector(
                                                    onTap: ()async{
                                                      if(_formKey.currentState!.validate()){
                                                        setState(() {
                                                          //code of reservation
                                                          _db.deleteReservationTime(_bookedTrainingList[index]);
                                                          _bookedTrainingList.clear();
                                                          Navigator.of(context).pop();
                                                        });
                                                      }
                                                    },
                                                    child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 20),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                        },
                                        child: Text("Code", style: TextStyle(color: Colors.white, fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    //reservation cancel
                                    Container(
                                      alignment: Alignment.center,
                                      width: scWidth*0.2,
                                      height: scHeight*0.05,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                                      child: GestureDetector(
                                        onTap: ()async{
                                          setState(() {
                                            //checking time of cancellation
                                            var splitDate = _bookedTrainingList[index].date!.split('-');
                                            String bookedTrainingReversedDate="";
                                            for(int i=2; i>=0 ;i--)
                                            {
                                              bookedTrainingReversedDate += splitDate[i];
                                              if(i!=0)
                                                bookedTrainingReversedDate += '-';
                                            }
                                            if(_currentDate.compareTo(bookedTrainingReversedDate)==0 &&
                                            _currentTime.compareTo(_bookedTrainingList[index].startTimeMinusOneHour.toString()) == 1){
                                              //warning & punishment
                                              showDialog(context: context, builder: (context){
                                                return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  title: Text('Cancellation agreement'),

                                                  content: Text(
                                                    'Please note that cancelling this reservation will ban matches\' reservation feature for three days.'
                                                        'Because cancellation option (if required) is allowed until maximum one hour prior to the reserved '
                                                        'slot timing.'
                                                  ),
                                                  actions: [
                                                    //agreement button
                                                    Container(
                                                      alignment: Alignment.center,
                                                      width: scWidth*0.2,
                                                      height: scHeight*0.05,
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                                                      child: GestureDetector(
                                                        onTap: ()async{
                                                            setState(() {
                                                              _db.deleteReservationTime(_bookedTrainingList[index]);
                                                              _bookedTrainingList.clear();
                                                              _db.setPunishmentDate(_punishmentDate);
                                                              UserData.punishmentDate = _punishmentDate;
                                                              Navigator.of(context).pop();
                                                            });
                                                        },
                                                        child: Text("Agree", style: TextStyle(color: Colors.white, fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });

                                            }
                                            else{
                                              _db.deleteReservationTime(_bookedTrainingList[index]);
                                              _bookedTrainingList.clear();
                                            }
                                          });
                                        },
                                        child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }, separatorBuilder: (BuildContext context, int index) => Divider(),);
                }
              }
              else
                return Center(child: Text('Error!', style: TextStyle(color: Colors.white)));
            },
          )
        ),
      )
    );
  }
}
