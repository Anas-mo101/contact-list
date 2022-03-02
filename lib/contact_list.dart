import 'dart:async';
import 'package:flutter/material.dart';
import 'contact.dart';
import 'api_handler.dart';
import 'package:share_plus/share_plus.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final scontroller = ScrollController();
  late List<Contact> Contacts = [];
  var dataLength = 0;
  var viewLength = 9;
  var timestampflag = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getContacts();
    scontroller.addListener(() {
      if (scontroller.position.atEdge) {
        final pos = scontroller.position.pixels == 0;
        if (!pos) {
          if (viewLength == dataLength) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('You have reached end of the list',
                  textAlign: TextAlign.center),
              backgroundColor: Color(0x660000dd),
            ));
          }
          setState(() {
            loading = true;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            setState(() {
              if (viewLength + 5 < dataLength) {
                viewLength += 5;
              } else {
                viewLength = dataLength;
              }
              loading = false;
            });
          });
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
                  timestampView(timestampflag);
                },
                child: const Icon(
                  Icons.date_range,
                  size: 26.0,
                ),
              ))
        ],
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Expanded(
              child: RefreshIndicator(
                  onRefresh: genContacts,
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: scontroller,
                    itemCount: viewLength,
                    itemBuilder: (BuildContext context, int index) {
                      Contacts.sort((a, b) {
                        return a.compareTo(b);
                      });
                      return ListTile(
                        leading: const Icon(
                          Icons.person,
                          size: 40,
                        ),
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
                        trailing: GestureDetector(
                          onTap: () {
                            share(Contacts[index]);
                          },
                          child: const Icon(
                            Icons.share,
                            size: 26.0,
                          ),
                        ),
                      );
                    },
                  ))),
          Container(
              margin: const EdgeInsets.all(0),
              child: loading
                  ? const LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      backgroundColor: Colors.white,
                      color: Colors.blue,
                      minHeight: 10,
                    )
                  : null),
        ],
      )),
    );
  }

  share(Contact con) {
    Share.share(
        'Contact: ${con.name} \n Phone: ${con.phone} \n Added at: ${con.checkin}');
  }

  Future<void> genContacts() async {
    List<Contact> newContacts = await generateContacts();
    setState(() {
      for (int i = 0; i < newContacts.length; i++) {
        Contacts.add(newContacts[i]);
        dataLength++;
      }
    });
    updateDatabaseContacts(newContacts);
  }

  Future<void> timestampView(bool current) async {
    setState(() {
      timestampflag = current ? false : true;
    });
    await timestampSwitch(current);
    getContacts();
  }

  Future<void> getContacts() async {
    List<Contact> contacts = await fetchContacts();
    bool fdata = await getTimestamp();
    setState(() {
      timestampflag = fdata;
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
