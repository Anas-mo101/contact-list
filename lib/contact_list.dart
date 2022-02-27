import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final scontroller = ScrollController();
  late List<Contact> Contacts;
  var dataLength;

  @override
  void initState() {
    super.initState();
    refreshContacts();
    scontroller.addListener(() {
      if (scontroller.position.atEdge) {
        final pos = scontroller.position.pixels == 0;
        if (!pos) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You have reached end of the list',
                textAlign: TextAlign.center),
            backgroundColor: Color(0x660000dd),
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact List")),
      body: Center(
        child: FutureBuilder(
          builder: (context, snapshot) {
            // showData = json.decode(snapshot.data.toString());
            return RefreshIndicator(
                onRefresh: genContacts,
                child: ListView.builder(
                  controller: scontroller,
                  itemCount: dataLength,
                  itemBuilder: (BuildContext context, int index) {
                    Contacts.sort((a, b) {
                      return a.compareTo(b);
                    });
                    return ListTile(
                      // leading: Icon(Flutter),
                      isThreeLine: true,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(Contacts[index].name),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Contacts[index].phone),
                          Text(parseCheckIn(Contacts[index].checkin))
                        ],
                      ),
                    );
                  },
                ));
          },
        ),
      ),
    );
  }

  Future<void> genContacts() async {
    var names = await http.get(
        Uri.parse('https://randommer.io/api/Name?nameType=fullname&quantity=5'),
        headers: {"X-Api-Key": "97fbe4ad9b914a38a4acb129eb0b6c1b"});
    var phones = await http.get(
        Uri.parse(
            'https://randommer.io/api/Phone/Generate?CountryCode=my&Quantity=5'),
        headers: {"X-Api-Key": "97fbe4ad9b914a38a4acb129eb0b6c1b"});

    if (names.statusCode == 200 && phones.statusCode == 200) {
      var name = json.decode(names.body);
      var phone = json.decode(phones.body);
      for (int i = 0; i < 5; i++) {
        var now = DateTime.now().toString();
        Contact newContact = new Contact(name[i], phone[i], now);
        setState(() {
          Contacts.add(newContact);
          dataLength++;
        });
      }
      // updateDatabase();
    } else {
      throw Exception('Api Failed');
    }
  }

  Future<void> refreshContacts() async {
    //genContacts();
    String response = await rootBundle.loadString('assets/contacts.json');
    var data = await json.decode(response);
    List<Contact> contacts =
        List<Contact>.from(data.map((i) => Contact.fromJson(i)));
    setState(() {
      Contacts = contacts;
      dataLength = contacts.length;
    });
  }

  parseCheckIn(timestamp) {
    var now = DateTime.now();
    var date = DateTime.parse(timestamp);
    var diff = now.difference(date);

    if (diff.inSeconds < 1) {
      return "now";
    } else if (diff.inSeconds >= 1 && diff.inSeconds < 60) {
      return diff.inSeconds.toString() + " seconds ago";
    } else if (diff.inMinutes >= 1 && diff.inMinutes < 60) {
      return diff.inMinutes.toString() + " minutes ago";
    } else if (diff.inHours >= 1 && diff.inHours < 24) {
      return diff.inHours.toString() + " hours ago";
    } else if (diff.inDays >= 1 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        return diff.inDays.toString() + " day ago";
      } else {
        return diff.inDays.toString() + " days ago";
      }
    } else if (diff.inDays >= 7 && diff.inDays < 30) {
      if (diff.inDays >= 7 && diff.inDays < 14) {
        return "one week ago";
      } else if (diff.inDays >= 14 && diff.inDays < 21) {
        return "two weeks ago";
      } else if (diff.inDays >= 21 && diff.inDays < 30) {
        return "three weeks ago";
      }
    } else {
      return "more than a month ago";
    }
  }
}

class Contact implements Comparable<Contact> {
  String name;
  String phone;
  String checkin;
  Contact(this.name, this.phone, this.checkin);

  factory Contact.fromJson(dynamic json) {
    return Contact(json['user'] as String, json['phone'] as String,
        json['check-in'] as String);
  }

  @override
  int compareTo(Contact other) {
    int flag = DateTime.parse(checkin).compareTo(DateTime.parse(other.checkin));
    if (flag == 1) {
      return -1;
    } else if (flag == -1) {
      return 1;
    } else {
      return 0;
    }
  }
}
