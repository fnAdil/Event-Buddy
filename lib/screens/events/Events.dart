import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasedemo/components/bacground.dart';
import 'package:firebasedemo/screens/register%20and%20login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'event_search_page.dart';

class Events extends StatefulWidget {
  const Events({
    Key? key,
  }) : super(key: key);

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  FirebaseAuth _userInstance = FirebaseAuth.instance;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _selectedCity = "İzmir";

  bool isCalendarOpen = true;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      const Background(),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            openCalendar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Cities(),
                EventSearchButton("Etkinlik Ara", _selectedDay),
              ],
            ),
          ],
        )),
      )
    ]);
  }

  Container Cities() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25), color: Colors.white70),
      child: DropdownButton(
        value: _selectedCity,
        elevation: 16,
        borderRadius: BorderRadius.circular(25),
        style: TextStyle(color: Colors.black),
        icon: const Icon(Icons.arrow_downward),
        items: <String>['İzmir', 'İstanbul', 'Bursa', 'Antalya', 'Ankara']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCity = value.toString();
          });
        },
      ),
    );
  }

  signOut() async {
    await _userInstance.signOut().then((value) => {
          Navigator.pop(context),
          Navigator.pop(context),
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Login()))
        });
  }

  GestureDetector EventSearchButton(String title, DateTime selectedDate) {
    DateTime _date =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    print(_date);
    return GestureDetector(
      onTap: () {
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventSearch(
                        city: _selectedCity,
                        date: _date,
                      )));
        });
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 35),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25), color: Colors.white70),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 20),
          )),
    );
  }

  Container openCalendar() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Center(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _selectedDay,
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.purple),
                formatButtonShowsNext: false,
                formatButtonTextStyle: TextStyle(color: Colors.lightBlue),
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  print(selectedDay);
                  _selectedDay = selectedDay;
                  _focusedDay =
                      selectedDay; // update `_focusedDay` here as well
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDay = DateTime.now();
                      });
                    },
                    child: Text(
                      "Bugün",
                      style: TextStyle(color: Colors.purple),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
