import 'package:firebase_database/firebase_database.dart';

class Category {
  String key;
  String name;
  int price;
  bool isActive;
  String userId;
  DateTime modifiedDate;

  Category(this.name, this.price, this.isActive, this.userId);

  Category.fromJson(Map<dynamic, dynamic> json) :
        key = json["key"],
        userId = json["userId"],
        name = json["name"],
        price = json["price"],
        isActive = json["isActive"],
        modifiedDate = new DateTime.fromMillisecondsSinceEpoch(json["modifiedDate"]);

  Category.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        name = snapshot.value["name"],
        price = snapshot.value["price"],
        isActive = snapshot.value["isActive"],
        modifiedDate = new DateTime.fromMillisecondsSinceEpoch(snapshot.value["modifiedDate"]);

  toJson() {
    return {
      "userId": userId,
      "name": name,
      "price": price,
      "isActive": isActive,
      "modifiedDate": DateTime.now().millisecondsSinceEpoch
    };
  }
}