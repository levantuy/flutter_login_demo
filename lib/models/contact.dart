import 'package:firebase_database/firebase_database.dart';

class Contact {
  String key;

  String name;

  String phone;

  String email;

  String address;

  String latitude;

  String longitude;

  String contactImage;

  String userId;

  Contact(this.name, this.phone, this.email, this.address, this.latitude, this.longitude, this.contactImage, this.userId);

  Contact.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        name = snapshot.value["name"],
        phone = snapshot.value["phone"],
        email = snapshot.value["email"],
        address = snapshot.value["address"],
        latitude = snapshot.value["latitude"],
        longitude = snapshot.value["longitude"],
        userId = snapshot.value["userId"],
        contactImage = snapshot.value["contactImage"];

  toJson() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "userId": userId,
      "contactImage": contactImage
    };
  }
}