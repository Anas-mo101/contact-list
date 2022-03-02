import 'package:flutter/material.dart';
import 'contact_list.dart';
import 'contact.dart';
import 'general.dart';
import 'api_handler.dart';

class SearchPage extends StatefulWidget {
  List<Contact> contacts = [];

  SearchPage({Key? key, required this.contacts}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Contact> contactlist = [];
  var dataLength = 0;
  TextEditingController scontroller = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scontroller.addListener(_findResult);
  }

  _findResult() {
    setState(() {
      contactlist = [];
      dataLength = 0;
    });
    if (scontroller.text.isNotEmpty) {
      for (var element in widget.contacts) {
        if (element
            .getName()
            .toLowerCase()
            .contains(scontroller.text.toLowerCase())) {
          setState(() {
            contactlist.add(element);
            dataLength++;
          });
        } else {
          if (contactlist.contains(element)) {
            setState(() {
              contactlist.remove(element);
              dataLength--;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactList()),
            );
          },
          child: const Icon(
            Icons.arrow_back,
            size: 26.0,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Contact Name",
                contentPadding: EdgeInsets.all(10.0),
              ),
              controller: scontroller,
            ),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: dataLength,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    leading: const Icon(
                      Icons.person,
                      size: 40,
                    ),
                    isThreeLine: true,
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(contactlist[index].name),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(contactlist[index].phone),
                        Text(parseCheckIn(contactlist[index].checkin, true))
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            share(widget.contacts[index]);
                          },
                          child: const Icon(
                            Icons.share,
                            size: 26.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            delContactAction(widget.contacts[index]);
                          },
                          child: const Icon(
                            Icons.delete,
                            size: 26.0,
                          ),
                        )
                      ],
                    ));
              },
            ))
          ],
        ),
      ),
    );
  }

  Future<void> delContactAction(Contact contact) async {
    setState(() {
      contactlist.remove(contact);
      dataLength--;
    });
    await delContact(contact);
  }
}
