import 'package:flutter/services.dart';
import 'package:flutter_login_demo/models/calculator.dart';
import 'package:flutter_login_demo/models/category.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class CalculatorPage extends StatefulWidget {
  CalculatorPage(
      {Key key, this.auth, this.userId, this.calculator})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final Calculator calculator;

  @override
  State<StatefulWidget> createState() => new _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  List<Calculator> _todoList;
  List<Category> _categoryList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _payDateEditingController = TextEditingController();
  final _money = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String dropdownValue = 'Tay áo';
  Calculator entity;
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  StreamSubscription<Event> _onCategoryAddedSubscription;
  StreamSubscription<Event> _onCategoryChangedSubscription;

  Query _todoQuery;
  Query _categoryQuery;

  @override
  void initState() {
    super.initState();

    setState(() {
      entity = widget.calculator;
    });

    if (entity == null) {
      _money.text = '0';
      _payDateEditingController.text =
          DateFormat.yMMMd().format(DateTime.now());
    } else {
      dropdownValue = entity.category.name;
      _money.text = entity.count.toString();
      _payDateEditingController.text =
          DateFormat.yMMMd().format(entity.calDate);
    }

    _todoList = new List();
    _categoryList = new List();

    _todoQuery = _database
        .reference()
        .child("calculator")
        .orderByChild("userId")
        .equalTo(widget.userId);

    _categoryQuery = _database
        .reference()
        .child("category")
        .orderByChild("userId")
        .equalTo(widget.userId);

    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChanged);

    _onCategoryAddedSubscription =
        _categoryQuery.onChildAdded.listen(onEntryAdded1);
    _onCategoryChangedSubscription =
        _categoryQuery.onChildChanged.listen(onEntryChanged1);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Calculator.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Calculator.fromSnapshot(event.snapshot));
    });
  }

  onEntryChanged1(Event event) {
    var oldEntry = _categoryList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _categoryList[_categoryList.indexOf(oldEntry)] =
          Category.fromSnapshot(event.snapshot);
    });
  }

  onEntryAdded1(Event event) {
    setState(() {
      _categoryList.add(Category.fromSnapshot(event.snapshot));
    });
  }

  plusOrSubtract(DateTime payDate, int money, Category category) {
    if (money > 0) {
      Calculator todo =
          new Calculator(payDate, category, money, widget.userId);
      print(todo);
      if (entity == null) {
        print(entity);
        entity = new Calculator(payDate, category, money, widget.userId);
        var id = _database.reference().child("calculator").push().key;
        _database.reference().child("calculator").child(id).set(todo.toJson());
        _database
            .reference()
            .child("calculator")
            .child(id)
            .once()
            .then((DataSnapshot snapshot) => {entity.key = snapshot.key});
      } else
        _database.reference().child("calculator").child(entity.key).set(todo.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đếm sản lượng'),
      ),
      body: Center(
          child: new Card(child: SingleChildScrollView(
              child: Column(
        children: <Widget>[
          Row(children: [
            new Expanded(
                child: ButtonTheme(
                    height: 70.0,
                    child: new RaisedButton(
                        elevation: 5.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.redAccent,
                        child: Icon(Icons.remove, size: 70),
                        onPressed: () {
                          _money.text = (int.parse(_money.text.toString()) - 1)
                              .toString();
                          plusOrSubtract(selectedDate,
                              int.parse(_money.text.toString()), _categoryList.firstWhere((element) => element.key == dropdownValue));
                        })))
          ]),
          Row(children: [
            new Expanded(
                child: new TextField(
              maxLengthEnforced: false,
              maxLines: null,
              controller: _payDateEditingController,
              decoration: InputDecoration(
                labelText: "Ngày tính",
                hintText: "Ex. 2020/06/01",
              ),
              style: TextStyle(
                  fontSize: 20.0, height: 2.0, color: Colors.black),
              onTap: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                final DateTime date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100));
                _payDateEditingController.text =
                    DateFormat.yMMMd().format(date);
                selectedDate = date;
              },
            ))
          ]),
          Row(children: [
            new Expanded(
                child: new DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(
                  fontSize: 20.0, height: 2.0, color: Colors.black),
              onChanged: (String newValue) {
                dropdownValue = newValue;
              },
              items:
                  _categoryList.map<DropdownMenuItem<String>>((Category value) {
                return DropdownMenuItem<String>(
                  value: value.name,
                  child: Text(value.name),
                );
              }).toList(),
            ))
          ]),
          Row(children: [
            new Expanded(
                child: new TextField(
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    maxLengthEnforced: false,
                    maxLines: null,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    controller: _money,
                    decoration: InputDecoration(
                      hintText: "ví dụ: 69"
                    ),
                    style: TextStyle(
                        fontSize: 70.0, height: 2.0, color: Colors.black)))
          ]),
          Row(children: [
            new Expanded(
                child: ButtonTheme(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    height: 70.0,
                    child: new RaisedButton(
                        elevation: 5.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.blue,
                        child: Icon(Icons.add, size: 70),
                        onPressed: () {
                          _money.text = (int.parse(_money.text.toString()) + 1)
                              .toString();
                          plusOrSubtract(selectedDate,
                              int.parse(_money.text.toString()), _categoryList.firstWhere((element) => element.name == dropdownValue));
                        })))
          ])
        ],
      )))),
    );
  }
}
