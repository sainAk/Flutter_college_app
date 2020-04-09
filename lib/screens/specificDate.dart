import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:demo/models/attendanceModel.dart';
import 'package:demo/widgets/custom_circle.dart';

final List months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class SpecificDate extends StatefulWidget {
  final Map data;
  const SpecificDate({Key key, this.data}) : super(key: key);
  @override
  _SpecificDateState createState() =>
      _SpecificDateState(data['username'], data['password'], data['lnctu']);
}

class _SpecificDateState extends State<SpecificDate>
    with SingleTickerProviderStateMixin {
  int day;
  var month;
  int year;
  List data;
  double attendance = 0;
  int present;
  int totallectures;
  AnimationController _acontroller;
  final username;
  final password;
  final lnctu;
  bool isLoading = true;

  _SpecificDateState(this.username, this.password, this.lnctu);
  @override
  void initState() {
    super.initState();
    var date = DateTime.now();
    day = date.day;
    month = date.month;
    month = months[month - 1];
    year = date.year;
    load();
  }

  @override
  void dispose() {
    _acontroller.dispose();
    super.dispose();
  }

  void updateAttendance(String date, DateTime _date) {
    int difference = 1000000;
    dynamic closestData;
    bool isFound = false;
    for (var i in data) {
      if (i['date'] == date) {
        isFound = true;
        setState(() {
          attendance = i['percentage'];
        });
        break;
      } else {
        var date = i['date'].split(' ');
        var year = date[2];

        var month = (months.indexOf(date[1]) + 1).toString();
        if (month.length == 1) {
          month = '0' + month;
        }
        date = DateTime.parse('$year-$month-${date[0]}');
        var _difference = _date.difference(date).inDays;
        if (_difference.abs() < difference.abs()) {
          difference = _difference;
          closestData = i;
        }
      }
    }

    if (!isFound) {
      setState(() {
        attendance = closestData['percentage'];
        totallectures = closestData['totalLectures'];
        present = closestData['present'];
      });
    }
  }

  void load() async {
    try {
      dynamic res = await getdatewiseattendance(username, password, lnctu);

      setState(() {
        data = res;
        attendance = res[res.length - 1]['percentage'];
        present = res[res.length - 1]['present'];
        totallectures = res[res.length - 1]['totalLectures'];
        isLoading = false;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'SpecificDate',
      child: Scaffold(
          appBar: AppBar(title: Text('Attendance Till Date')),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: returnData(),
                  ),
                ),
                Text('As of $day $month $year', style: TextStyle(fontSize: 30)),
                // Align(alignment:Alignment.center,child: CustomCircle()),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: showDate(context),
                ),
                // Text('Attendance till ${DateTime.now()}')
              ],
            ),
          )),
    );
  }

  Widget returnData() {
    return Container(
      height: 300,
      child: Stack(children: [
        Center(
          child: TweenAnimationBuilder(
              curve: Curves.decelerate,
              duration: Duration(seconds: 1),
              tween: Tween<double>(begin: 0, end: attendance * pi * 2 / 100),
              builder: (_, double angle, __) {
                return CustomCircle(
                  angle: angle,
                );
              }),
        ),
        Align(
          alignment: Alignment.center,
          child: isLoading
              ? SpinKitDoubleBounce(color: Colors.green, size: 40)
              : Text(
                  '$attendance %',
                  style: TextStyle(fontSize: 35),
                ),
        ),
      ]),
    );
  }

  Widget showDate(BuildContext context) {
    return RaisedButton(
        onPressed: () async {
          try {
            var response = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2015, 8),
                lastDate: DateTime(2101));
            setState(() {
              day = response.day;
              month = months[response.month - 1];
              year = response.year;
              updateAttendance('$day $month $year', response);
            });
          } catch (e) {
            print(e);
          }
        },
        color: Colors.green,
        child: Text(
          'Change Date',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ));
  }
}