import 'package:firebase_database/firebase_database.dart';

class Todo {
  String key;
  String subject;
  bool completed;
  String userId;
  int money;
  DateTime payDate;

  Todo(this.subject, this.userId, this.completed, this.payDate, this.money);

  Todo.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    subject = snapshot.value["subject"],
    completed = snapshot.value["completed"],
    money = snapshot.value["money"],
    payDate = new DateTime.fromMillisecondsSinceEpoch(snapshot.value["payDate"]);

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "money": money,
      "payDate": payDate.millisecondsSinceEpoch,
    };
  }
}