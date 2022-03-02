import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'contact.dart';
import 'api_handler.dart';
import 'search.dart';
import 'general.dart';

class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final scontroller = ScrollController();
  TextEditingController tcontroller = TextEditingController();
  TextEditingController ncontroller = TextEditingController();
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchPage(
                        contacts: Contacts,
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.search,
                  size: 26.0,
                ),
              )),
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showForm();
                },
                child: const Icon(
                  Icons.person_add,
                  size: 26.0,
                ),
              )),
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
                          trailing: Wrap(
                            spacing: 12,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  share(Contacts[index]);
                                },
                                child: const Icon(
                                  Icons.share,
                                  size: 26.0,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  delContactAction(Contacts[index]);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  size: 26.0,
                                ),
                              )
                            ],
                          ));
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

  Future showForm() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Add New Contact"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: "Contact Name"),
                  controller: tcontroller,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: "Contact Number"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: ncontroller,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  addContactAction();
                },
              )
            ],
          ));

  Future<void> delContactAction(Contact contact) async {
    setState(() {
      Contacts.remove(contact);
      dataLength--;
    });
    await delContact(contact);
  }

  Future<void> addContactAction() async {
    Navigator.of(context).pop();
    if (tcontroller.text == " " || tcontroller.text.isEmpty) return;
    if (ncontroller.text == " " || ncontroller.text.isEmpty) return;
    setState(() {
      Contacts.add(Contact(
          tcontroller.text, ncontroller.text, DateTime.now().toString()));
      dataLength++;
    });
    await addContact(tcontroller.text, ncontroller.text);
  }

  Future<void> genContacts() async {
    List<Contact> newContacts = await generateContacts();
    setState(() {
      for (int i = 0; i < newContacts.length; i++) {
        Contacts.add(newContacts[i]);
        dataLength++;
      }
    });
    await updateDatabaseContacts(newContacts);
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
      viewLength = contacts.length < 9 ? contacts.length : 9;
    });
  }
}
