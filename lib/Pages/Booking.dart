import 'package:athletic_community/Models/BookedTraining.dart';
import 'package:athletic_community/Pages/AvailableClubs.dart';
import 'package:athletic_community/Services/Firestore.dart';
import 'package:athletic_community/Services/UserData.dart';
import 'package:athletic_community/UIHelp/MyAppBar.dart';
import 'package:athletic_community/UIHelp/SideMenuDrawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Booking extends StatefulWidget {
  String _clubName, _sportName, _membersNum, _bookingPrice;
  Booking(this._clubName, this._sportName, this._membersNum, this._bookingPrice);
  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  Database _db = new Database();

  late double scWidth;
  late double scHeight;
  String? _selectedDate;
  String? _selectedTime;
  bool _isReservationToday = false;
  bool _isTeamCompleted = false;
  int _skillGroupValue = 0;

  Stream? dateStream;
  getDateList()async{
    _db.getDateList(widget._clubName, widget._sportName).then((value){
      setState(() {
        dateStream = value;
      });
    });
  }

  Stream? timeStream;
  getTimeList()async{
    _db.getTimeSlotList(widget._clubName, widget._sportName, _selectedDate!).then((value){
      setState(() {
        timeStream = value;
      });
    });
  }

  Stream? teamMembersEmailStream;
  getTeamMembersEmails()async{
    _db.getTeamMembers(widget._clubName, widget._sportName, _selectedDate!, _selectedTime!).then((value){
      setState(() {
        teamMembersEmailStream = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDateList();
  }

  @override
  Widget build(BuildContext context) {
    scWidth = MediaQuery.of(context).size.width;
    scHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white10,
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

          child: Column(
            children: [
              //required number of team members
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text('Required number of team members:', style: TextStyle(color: Colors.black87, fontSize: 20),textAlign: TextAlign.center,),
                    Text('${widget._membersNum}', style: TextStyle(color: Colors.black87, fontSize: 20),textAlign: TextAlign.center,)
                  ],
                )
              ),

              //booking price
              Container(
                  width: scWidth*0.6,
                  height: scHeight*0.05,
                  decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Text('Booking Price: ${widget._bookingPrice} EGP', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),)),

              SizedBox(height: scHeight/20,),

              //date list
              StreamBuilder(
                stream: dateStream,
                builder: (context, AsyncSnapshot snap){
                  if(snap.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else if(snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.done) {
                    if (snap.hasError)
                      return Center(
                          child: Text('Error!',));
                    else if (snap.hasData == false)
                      return Center(child: Text('Empty Data', style: TextStyle(color: Colors.white)));
                    else{
                      //Get current day
                      DateTime _now = DateTime.now();
                      DateFormat formatter = DateFormat('yyyy-MM-dd');
                      String _currentDay = formatter.format(_now);

                      List<String> _dateList = [];
                      for(int i=0 ; i<snap.data.docs.length ; i++){
                        Map _dateMap = snap.data.docs[i].data();

                        //comparision must be between 'yyyy-MM-dd' & 'yyyy-MM-dd' not 'dd-MM-yyyy' & 'dd-MM-yyyy'
                        if(_dateMap['date'].compareTo(_currentDay) != -1) //check if this day is before today's day or not
                          {
                          _dateList.add(snap.data.docs[i].id);
                          }
                        else if(_dateMap['date'].compareTo(_currentDay) == -1)//remove old dates
                        {
                          _db.removeDate(widget._clubName, widget._sportName, snap.data.docs[i].id).then((value){
                            _dateList.clear();
                          });
                        }
                      }
                      return GestureDetector(
                        onTap: (){
                          if(_dateList.isEmpty)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('There are no available days')));
                          },
                        child: DropdownButton(
                            dropdownColor: Colors.white.withOpacity(0.9),
                            hint: Text('Select Date', style: TextStyle(color: Colors.black87),),
                            value: _selectedDate,
                            onChanged: (newValue){
                              //comparision must be between 'yyyy-MM-dd' & 'yyyy-MM-dd' not 'dd-MM-yyyy' & 'dd-MM-yyyy'
                              var splitDate = newValue.toString().split('-');
                              String reversedDate="";
                              for(int i=2; i>=0 ;i--)
                              {
                                reversedDate += splitDate[i];
                                if(i!=0)
                                  reversedDate += '-';
                              }

                              if(reversedDate.compareTo(_currentDay) == 0)//check the chosen date is today or not
                              {
                                setState(() {
                                  _isReservationToday = true;
                                  _selectedTime = null;
                                  _selectedDate = newValue as String;
                                });
                              }
                              else{
                                setState(() {
                                  _isReservationToday = false;
                                  _selectedTime = null;
                                  _selectedDate = newValue as String;
                                });
                              }
                              getTimeList();
                            },
                            items: _dateList.map((valueItem){
                              return DropdownMenuItem(
                                  value: valueItem,
                                  child: Text(valueItem, style: TextStyle(color: Colors.black87),)
                              );
                            }).toList(),

                          ),
                      );
                    }
                  }
                  else
                    return Center(child: Text('Error!'));
                },
              ),

              SizedBox(height: scHeight/20,),

              //time list
              _selectedDate==null?SizedBox():
              StreamBuilder(
                stream: timeStream,
                builder: (context, AsyncSnapshot snap){
                  if(snap.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else if(snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.done) {
                    if (snap.hasError)
                      return Center(
                          child: Text('Error!',));
                    else if (snap.hasData == false)
                      return Center(
                          child: Text('Empty Data',));
                    else{
                      //Get current time
                      DateTime _now = DateTime.now();
                      String _currentTime =  DateFormat('HH:mm').format(_now);

                      List<String> _timeList = [];
                      for(int i=0; i< snap.data.docs.length; i++)
                      {
                        Map _timeMap = snap.data.docs[i].data();
                        if(_isReservationToday == true && _timeMap['startTime'].compareTo(_currentTime) == -1){
                            _db.removeTimeSlot(widget._clubName, widget._sportName, _selectedDate!, snap.data.docs[i].id);
                            _timeList.clear();
                        }
                        else
                          _timeList.add(snap.data.docs[i].id);
                      }

                      return GestureDetector(
                        onTap: (){
                          if(_timeList.isEmpty)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('There are no available time slots in this day')));
                        },
                        child: DropdownButton(
                          dropdownColor: Colors.white.withOpacity(0.9),
                          hint: Text('Select Time Slot', style: TextStyle(color: Colors.black87),),
                          value: _selectedTime,
                          onChanged: (newValue){
                            setState(() {
                              _selectedTime = newValue as String;
                            });
                            getTeamMembersEmails();
                            },
                          items: _timeList.map((valueItem){
                            return DropdownMenuItem(
                                value: valueItem,
                                child: Text(valueItem, style: TextStyle(color: Colors.black87),)
                            );
                          }).toList(),
                        ),
                      );
                    }
                  }
                  else
                    return Center(child: Text('Error!',));
                  },
              ),

              SizedBox(height: scHeight/20,),

              //skill radio buttons
              _selectedTime==null?SizedBox():
              Container(
                width: scWidth*0.8,
                child: Column(
                  children: [
                    //Skill
                    Text(
                      'Your Skill: ',
                      style: TextStyle(fontSize: 20),
                    ),
                    //beginner
                    ListTile(
                      title: Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.black87),
                            child: Radio(
                                activeColor: Colors.black87,
                                value: 0,
                                groupValue: _skillGroupValue,
                                onChanged: (val) {
                                  setState(() {
                                    _skillGroupValue = val as int;
                                  });
                                }),
                          ),
                          Text('Beginner', style: TextStyle(color: Colors.black87),)
                        ],
                      ),
                    ),
                    //intermediate
                    ListTile(
                      title: Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.black87),
                            child: Radio(
                                activeColor: Colors.black87,
                                value: 1,
                                groupValue: _skillGroupValue,
                                onChanged: (val) {
                                  setState(() {
                                    _skillGroupValue = val as int;
                                  });
                                }),
                          ),
                          Text('Intermediate', style: TextStyle(color: Colors.black87))
                        ],
                      ),
                    ),
                    //experienced
                    ListTile(
                      title: Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.black87),
                            child: Radio(
                                activeColor: Colors.black87,
                                value: 2,
                                groupValue: _skillGroupValue,
                                onChanged: (val) {
                                  setState(() {
                                    _skillGroupValue = val as int;
                                  });
                                }),
                          ),
                          Text('Experienced', style: TextStyle(color: Colors.black87))
                        ],
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: scHeight/20,),

              //team members
              _selectedTime==null?SizedBox():
              StreamBuilder(
                stream: teamMembersEmailStream,
                builder: (context, AsyncSnapshot snap){

                  if(snap.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else if(snap.connectionState == ConnectionState.active || snap.connectionState == ConnectionState.done) {
                    if (snap.hasError)
                      return Center(
                          child: Text('Error!', style: TextStyle(color: Colors.white),));
                    else if (snap.hasData == false)
                      return Center(
                          child: Text('Empty Data', style: TextStyle(color: Colors.white)));
                    else{
                      List<String> _teamMembersList = [];

                      if(snap.data.docs.length == int.parse(widget._membersNum)){
                          _isTeamCompleted = true;
                      }
                      else if(snap.data.docs.length < int.parse(widget._membersNum)){
                          _isTeamCompleted = false;
                      }
                      for(int i=0; i< snap.data.docs.length; i++){
                        Map _teamMemberMap = snap.data.docs[i].data();
                        //_teamMembersMap['email'] --> email elly metsagel fe el ma3ad dh
                        _teamMembersList.add(_teamMemberMap['email']);
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Team members: ", style: TextStyle(fontSize: 15, color: Colors.black87),),

                          InkWell(
                            onTap: (){
                              showDialog(context: context, builder: (context){
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text('Team members'),
                                  content: Container(
                                    width: scWidth * 0.8,
                                    height: scHeight * 0.6,
                                    child: ListView.separated(
                                        itemCount: _teamMembersList.length,
                                        itemBuilder: (context, index){
                                          return Text('${_teamMembersList[index]}');
                                        },
                                        separatorBuilder: (BuildContext context, int index)=>Divider()
                                    ),
                                  ),
                                  actions: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: scWidth*0.2,
                                      height: scHeight*0.05,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                                      child: GestureDetector(
                                        onTap: ()async{
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK", style: TextStyle(fontSize: 25, color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                            },
                            child: Text('${snap.data.docs.length} members', style: TextStyle(fontSize: 15, color: Colors.black87, decoration: TextDecoration.underline)),
                          )
                        ],
                      );
                    }
                  }
                  else
                    return Center(child: Text('Error!', style: TextStyle(color: Colors.white)));


                },
              ),

              SizedBox(height: scHeight/20,),

              //confirm button
              _selectedTime==null?SizedBox():
              Container(
                alignment: Alignment.center,
                width: scWidth*0.3,
                height: scHeight*0.05,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                child: GestureDetector(
                  onTap: ()async{
                    setState(() {}); //to get the newest value of _isTeamCompleted
                    DateTime _now = DateTime.now();
                    DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
                    String _currentDate = _dateFormatter.format(_now);

                    if(_currentDate.compareTo(UserData.punishmentDate) == -1){//still at the punishment period
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                         title: Text('Can\'t Confirm'),
                         content: Text('Reservation feature is banned till '
                             '${UserData.punishmentDate.substring(8, 10)}-'//day
                             '${UserData.punishmentDate.substring(5, 7)}-'//month
                             '${UserData.punishmentDate.substring(0, 4)}'),//year
                          actions: [
                            //OK button
                            Container(
                              alignment: Alignment.center,
                              width: scWidth*0.2,
                              height: scHeight*0.05,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                              child: GestureDetector(
                                onTap: ()async{
                                    Navigator.of(context).pop();
                                },
                                child: Text("OK", style: TextStyle(color: Colors.white, fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                    }

                    else{
                      if(_isTeamCompleted == false){

                        BookedTraining _bookedTrainingInfo =
                        new BookedTraining(widget._clubName, widget._sportName, _selectedDate!, _selectedTime!, widget._bookingPrice);

                        //set data to _bookedTrainingInfo.startTimeMinusOneHour
                        String startTimeOfMatch = _selectedTime!.substring(0,5);
                        DateTime _startTimeOfMatch = DateFormat('HH:mm').parse(startTimeOfMatch);
                        _startTimeOfMatch = _startTimeOfMatch.subtract(Duration(hours: 1));
                        _bookedTrainingInfo.startTimeMinusOneHour = DateFormat('HH:mm').format(_startTimeOfMatch);

                        String _skill;
                        if(_skillGroupValue == 0)
                          _skill = 'Beginner';
                        else if(_skillGroupValue == 1)
                          _skill = 'Intermediate';
                        else
                          _skill = 'Experienced';

                        isReservationTimeBusy(_bookedTrainingInfo).then((_isReservationTimeBusy){

                          _db.isUserBookedThis(_bookedTrainingInfo).then((value){
                            if(value.data() == null){
                              if(_isReservationTimeBusy){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You have already a match at this time...")));
                              }

                              else{
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    title: Text('Confirmation'),
                                    content: Text(
                                        'Please note that not attending without prior cancellation will ban matches\' reservation feature for three days.'
                                            'Cancellation option (if required) is allowed until maximum one hour prior to the reserved '
                                            'slot timing.'
                                    ),//year
                                    actions: [
                                      //submit button
                                      Container(
                                        alignment: Alignment.center,
                                        width: scWidth*0.2,
                                        height: scHeight*0.05,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Colors.black87,),
                                        child: GestureDetector(
                                          onTap: ()async{
                                            _db.addReservationTime(_bookedTrainingInfo);
                                            _db.saveTeamMember(widget._clubName, widget._sportName, _selectedDate!, _selectedTime!, _skill).then((value){});
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Confirmed Successfully")));
                                            Navigator.of(context).pop();
                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AvailableClubs()), (route)=>false);
                                          },
                                          child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You have already booked this before...")));
                            }
                          });

                        });
                      }
                      else if(_isTeamCompleted){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Required num of team members has been completed")));
                      }
                    }
                  },
                  child:
                  Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center,),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  isReservationTimeBusy(BookedTraining _bookedTrainingInfo)async{

    return _db.checkingBusyReservationTime().then((value){

      bool _isReservationTimeBusy = false;
      for(int i=0 ; i < value.docs.length; i++){
        Map _reservationTimeMap = value.docs[i].data();
        if(_reservationTimeMap['date'] == _bookedTrainingInfo.date && _reservationTimeMap['time'] == _bookedTrainingInfo.time){
          _isReservationTimeBusy = true;
        }
      }
      return _isReservationTimeBusy;

    });
  }
}
