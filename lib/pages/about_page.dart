import 'dart:developer';

import 'package:flutter_login_demo/common/avatar.dart';
import 'package:flutter_login_demo/models/calculator.dart';
import 'package:flutter_login_demo/models/category.dart';
import 'package:flutter_login_demo/models/contact.dart';
import 'package:flutter_login_demo/util/constants.dart';
import 'package:flutter_login_demo/util/functions.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  AboutPage(
      {Key key, this.auth, this.userId})
      : super(key: key);

  final BaseAuth auth;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<Contact> contactList;
  RectTween _createRectTween(Rect begin, Rect end) {
    return new MaterialRectCenterArcTween(begin: begin, end: end);
  }

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _payDateEditingController = TextEditingController();
  final _money = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String dropdownValue;
  Calculator entity;
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  @override
  void initState() {
    super.initState();

    contactList = new List();

    _todoQuery = _database
        .reference()
        .child("contact")
        .orderByChild("userId")
        .equalTo(widget.userId);

    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = contactList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      contactList[contactList.indexOf(oldEntry)] =
          Contact.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      contactList.add(Contact.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About me'),
      ),
      body: _contactDetails()
    );
  }

  Widget _contactDetails() {
    if (contactList.length == 0)
      return Center(
          child: Text(
        "Loading... ",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));

    return ListView(
      children: <Widget>[
        new SizedBox(
          child: new Hero(
            createRectTween: _createRectTween,
            tag: contactList[0].key,
            child: new Avatar(
              contactImage: contactList[0].contactImage,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          height: 200.0,
        ),
        listTile(contactList[0].name, Icons.account_circle, Texts.NAME),
        listTile(contactList[0].phone, Icons.phone, Texts.PHONE),
        listTile(contactList[0].email, Icons.email, Texts.EMAIL),
        listTile(contactList[0].address, Icons.location_on, Texts.ADDRESS),
        new Row(
          children: <Widget>[
            new Flexible(
              child:
              listTile(contactList[0].latitude, Icons.my_location, Texts.LATITUDE),
              fit: FlexFit.tight,
            ),
            new Flexible(
              child: listTile(
                  contactList[0].longitude, Icons.my_location, Texts.LONGITUDE),
              fit: FlexFit.tight,
            ),
          ],
        )
      ],
    );
  }

  Widget listTile(String text, IconData icon, String tileCase) {
    return new GestureDetector(
      onTap: () {
        switch (tileCase) {
          case Texts.NAME:
            break;
          case Texts.PHONE:
            _launch("tel:" + contactList[0].phone);
            break;
          case Texts.EMAIL:
            _launch("mailto:${contactList[0].email}?");
            break;
          case Texts.ADDRESS:
            _launch(googleMapUrl(contactList[0].latitude, contactList[0].longitude));
            break;
          case Texts.LATITUDE:
            _launch(googleMapUrl(contactList[0].latitude, contactList[0].longitude));
            break;
          case Texts.LONGITUDE:
            _launch(googleMapUrl(contactList[0].latitude, contactList[0].longitude));
            break;
        }
      },
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(
              text,
              style: new TextStyle(
                color: Colors.blueGrey[400],
                fontSize: 20.0,
              ),
            ),
            leading: new Icon(
              icon,
              color: Colors.blue[400],
            ),
          ),
          new Container(
            height: 0.3,
            color: Colors.blueGrey[400],
          )
        ],
      ),
    );
  }

  void _launch(String launchThis) async {
    try {
      String url = launchThis;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print("Unable to launch $launchThis");
//        throw 'Could not launch $url';
      }
    } catch (e) {
      print("My custom exception: " + e.toString());
    }
  }
}
