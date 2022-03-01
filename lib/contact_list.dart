import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'contact.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final scontroller = ScrollController();
  late List<Contact> Contacts = [];
  var dataLength = 0;
  var timestampflag = true;

  @override
  void initState() {
    super.initState();
    getContacts();
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
      appBar: AppBar(
        title: const Text("Contact List"),
        leading: const Icon(Icons.menu),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  timestampSwitch(timestampflag);
                },
                child: const Icon(
                  Icons.date_range,
                  size: 26.0,
                ),
              ))
        ],
      ),
      body: Center(
        child: FutureBuilder(
          builder: (context, snapshot) {
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
                      leading: const Icon(Icons.person),
                      isThreeLine: true,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(Contacts[index].name),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(Contacts[index].phone),
                          Text(parseCheckIn(
                              Contacts[index].checkin, timestampflag))
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
        var now = DateTime.now().toString();
        Contact newContact = Contact(name[i], phone[i], now);
        newContacts.add(newContact);
        setState(() {
          Contacts.add(newContact);
          dataLength++;
        });
      }
      updateDatabase(newContacts); // add newly generated contacts to database
    } else {
      throw Exception('Api Failed');
    }
  }

  void timestampSwitch(bool current) {
    var flag;
    if (current) {
      flag = false;
    } else {
      flag = true;
    }
    setState(() {
      timestampflag = flag;
    });
    getContacts();
  }

  void updateDatabase(List<Contact> cons) async {
    String jsonContacts = jsonEncode(cons);
    var response = await http.post(
        Uri.parse('http://localhost:3000/addcontacts'),
        headers: {"Content-Type": "application/json"},
        body: jsonContacts);
  }

  Future<void> getContacts() async {
    List<Contact> contacts = [];
    var data;
    try {
      var _contacts =
          await http.get(Uri.parse('http://localhost:3000/getcontacts'));
      if (_contacts.statusCode == 200) {
        data = await json.decode(_contacts.body);
        // print(data);
        contacts = List<Contact>.from(data.map((i) => Contact.fromJson(i)));
      }
    } catch (e) {
      print("fetching data failed");
      print(e);
    }
    setState(() {
      Contacts = contacts;
      dataLength = contacts.length;
    });
  }

  parseCheckIn(timestamp, flag) {
    if (flag) {
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
    } else {
      return timestamp;
    }
  }
}
