import 'package:flutter/services.dart';
import 'package:flutter_login_demo/models/calculator.dart';
import 'package:flutter_login_demo/models/category.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class CountPage extends StatefulWidget {
  CountPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _CountPageState();
}

class _CountPageState extends State<CountPage> {
  List<Calculator> _todoList;
  List<Category> _categoryList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _payDateEditingController = TextEditingController();
  final _money = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String dropdownValue = 'Tay áo';
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  StreamSubscription<Event> _onCategoryAddedSubscription;
  StreamSubscription<Event> _onCategoryChangedSubscription;

  Query _todoQuery;
  Query _categoryQuery;

  @override
  void initState() {
    super.initState();

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

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  addNewTodo(DateTime payDate, int money, String categoryId) {
    if (categoryId.length > 0) {
      Calculator todo =
      new Calculator(payDate, categoryId, money, widget.userId);
      _database.reference().child("calculator").push().set(todo.toJson());
    }
  }

  subtract(DateTime payDate, int money, String categoryId) {
    if (categoryId.length > 0) {
      Calculator todo =
      new Calculator(payDate, categoryId, money, widget.userId);
      _database.reference().child("calculator").push().set(todo.toJson());
    }
  }

  updateTodo(Calculator todo) {
    //Toggle completed
    /* todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("calculator").child(todo.key).set(todo.toJson());
    } */
  }

  deleteTodo(String todoId, int index) {
    _database.reference().child("calculator").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  showAddTodoDialog(BuildContext context) async {
    _payDateEditingController.clear();
    _money.clear();
    print('OPEN DIALOG ${_categoryList[0].name}');
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
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
                            onChanged: (String newValue) {
                              dropdownValue = newValue;
                            },
                            items: _categoryList
                                .map<DropdownMenuItem<String>>((Category value) {
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
                            maxLengthEnforced: false,
                            maxLines: null,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            // Only numbers can be entered
                            controller: _money,
                            decoration: InputDecoration(
                              labelText: "Số lượng",
                              hintText: "ví dự. 6800",
                            ),
                          ))
                    ])
                  ],
                )),
            actions: <Widget>[
              new FlatButton(
                  child: Icon(Icons.remove),
                  onPressed: () {
                    _money.text = (int.parse(_money.text.toString()) - 1).toString();
                    subtract(selectedDate, int.parse(_money.text.toString()),
                        dropdownValue);
                  }),
              new FlatButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    _money.text = (int.parse(_money.text.toString()) + 1).toString();
                    addNewTodo(selectedDate, int.parse(_money.text.toString()),
                        dropdownValue);
                  })
            ],
          );
        });
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String calculatorId = _todoList[index].key;
            String categoryId = _todoList[index].categoryId;
            int count = _todoList[index].count;
            String userId = _todoList[index].userId;
            var calDateFormat =
                DateFormat.yMMMd().format(_todoList[index].calDate) +
                    " - " +
                    _todoList[index].count.toString(); // Apr 8, 2020 - 6800
            return Dismissible(
              key: Key(calculatorId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                deleteTodo(calculatorId, index);
              },
              child: ListTile(
                title: Text(
                  categoryId,
                  style: TextStyle(fontSize: 20.0),
                ),
                subtitle: Text(
                  calDateFormat,
                  style: TextStyle(fontSize: 14.0),
                ),
                trailing: IconButton(
                    icon: Icon(
                      Icons.done_outline,
                      color: Colors.green,
                      size: 20.0,
                    ),
                    onPressed: () {
                      updateTodo(_todoList[index]);
                    }),
              ),
            );
          });
    } else {
      return Center(
          child: Text(
            "Welcome. Your list is empty",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(title: Text('Personal finance')),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("Tuy LV"),
                accountEmail: Text("levantuy.it@gmail.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? Colors.blue
                      : Colors.white,
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
              ListTile(
                title: Text("About me"),
                trailing: Icon(Icons.account_box),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Logout"),
                trailing: Icon(Icons.exit_to_app),
                onTap: () => signOut(),
              ),
            ],
          ),
        ), //this will just add the Navigation Drawer Icon
        body: showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddTodoDialog(context);
          },
          tooltip: 'Add',
          child: Icon(Icons.add),
        ));
  }
}
