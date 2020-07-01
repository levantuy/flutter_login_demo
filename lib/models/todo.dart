import 'package:firebase_database/firebase_database.dart';

class Todo {
  String key;
  String subject;
  bool completed;
  String userId;
  String payDate;

  Todo(this.subject, this.userId, this.completed, this.payDate);

  Todo.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    subject = snapshot.value["subject"],
    completed = snapshot.value["completed"],
    payDate = snapshot.value["payDate"];

  toJson() {
    return {
      "userId": userId,
      "subject": subject,
      "completed": completed,
      "payDate": payDate,
    };
  }
}