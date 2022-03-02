import 'package:http/http.dart' as http;
import 'dart:async';
import 'contact.dart';
import 'dart:convert';

Future<List<Contact>> generateContacts() async {
  var names = await http.get(
      Uri.parse(
          'https://randommer.io/api/Name?nameType=fullname&quantity=5'), // limited to 1000 call/day
      headers: {"X-Api-Key": "97fbe4ad9b914a38a4acb129eb0b6c1b"});
  var phones = await http.get(
      Uri.parse(
          'https://randommer.io/api/Phone/Generate?CountryCode=my&Quantity=5'), // limited to 1000 call/day
      headers: {"X-Api-Key": "97fbe4ad9b914a38a4acb129eb0b6c1b"});

  if (names.statusCode == 200 && phones.statusCode == 200) {
    late List<Contact> newContacts = [];
    var name = json.decode(names.body);
    var phone = json.decode(phones.body);

    for (int i = 0; i < 5; i++) {
      String _phone = phone[i].replaceAll(' ', '');
      _phone = _phone.replaceAll('+', '');
      _phone = _phone.replaceAll('-', '');
      var now = DateTime.now().toString();
      Contact newContact = Contact(name[i], _phone, now);
      newContacts.add(newContact);
    }
    updateDatabaseContacts(
        newContacts); // add newly generated contacts to database
    return newContacts;
  } else {
    throw Exception('Api Failed');
  }
}

Future<void> timestampSwitch(bool current) async {
  bool _flag = current ? false : true;
  var response = await http.post(
      Uri.parse('http://localhost:3000/settimestamp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'flag': _flag}));
  if (response.statusCode != 200) {
    throw Exception('Api Failed');
  }
}

Future<void> updateDatabaseContacts(List<Contact> cons) async {
  String jsonContacts = jsonEncode(cons);
  var response = await http.post(Uri.parse('http://localhost:3000/addcontacts'),
      headers: {"Content-Type": "application/json"}, body: jsonContacts);
  if (response.statusCode != 200) {
    throw Exception('Api Failed');
  }
}

Future<List<Contact>> fetchContacts() async {
  List<Contact> contacts = [];
  var cdata;
  try {
    var _contacts =
        await http.get(Uri.parse('http://localhost:3000/getcontacts'));
    if (_contacts.statusCode == 200) {
      cdata = await json.decode(_contacts.body);
      contacts = List<Contact>.from(cdata.map((i) => Contact.fromJson(i)));
    } else {
      throw Exception('Api Failed');
    }
  } catch (e) {
    print(e);
  }
  return contacts;
}

Future<bool> getTimestamp() async {
  var _flag = await http.get(Uri.parse('http://localhost:3000/gettimestamp'));
  var fdata = await json.decode(_flag.body);
  if (_flag.statusCode != 200) {
    throw Exception('Api Failed');
  }
  return fdata;
}

Future<void> addContact(String name, String phone) async {
  var now = DateTime.now();
  String jsonContacts =
      '{"user": "$name", "phone": "$phone", "checkin": "$now"}';
  var response = await http.post(Uri.parse('http://localhost:3000/addcontact'),
      headers: {"Content-Type": "application/json"}, body: jsonContacts);
  if (response.statusCode != 200) {
    throw Exception('Api Failed');
  }
}

Future<void> delContact(Contact contact) async {
  String jsonContacts =
      '{"user": "${contact.name}", "phone": "${contact.phone}", "checkin": "${contact.checkin}"}';
  var response = await http.post(Uri.parse('http://localhost:3000/delcontact'),
      headers: {"Content-Type": "application/json"}, body: jsonContacts);
  if (response.statusCode != 200) {
    throw Exception('Api Failed');
  }
}
