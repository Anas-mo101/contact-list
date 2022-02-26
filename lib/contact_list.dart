import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ContactList extends StatefulWidget {
  const ContactList({ Key? key }) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final scontroller = ScrollController();
  var showData;

  @override
  void initState(){
    super.initState();
    refreshContacts();
    scontroller.addListener(() {
      if(scontroller.position.atEdge){
        final pos = scontroller.position.pixels == 0;
        if(!pos){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have reached end of the list', textAlign: TextAlign.center),
              backgroundColor: Color(0x660000dd),
            )
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact List")),
      body: Center(
        child: FutureBuilder(builder: (context, snapshot){
          // showData = json.decode(snapshot.data.toString());
          return RefreshIndicator(
            onRefresh: refreshContacts,
            child: ListView.builder(
              controller: scontroller,
              itemCount: showData.length,
              itemBuilder: (BuildContext context, int index){
                showData.sort((a, b){ //sorting in ascending order
                    return DateTime.parse(b['check-in']).compareTo(DateTime.parse(a['check-in']));
                });
                return ListTile(
                  //leading: Icon,
                  isThreeLine: true,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(showData[index]['user']),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(showData[index]['phone']),
                      Text(parseCheckIn(showData[index]['check-in']))
                    ],),
                ); 
              },
            )
          );
        },//future: DefaultAssetBundle.of(context).loadString("assets/contacts.json"),
        ),
      ),
    );
  }

  Future<void> refreshContacts() async {
    final String response = await rootBundle.loadString('assets/contacts.json');
    final data = await json.decode(response);
    setState(() {
      showData = data;
    });
  }

  parseCheckIn(timestamp){
    var now = DateTime.now();
    var date = DateTime.parse(timestamp);
    var diff = now.difference(date);
    
    if(diff.inSeconds >= 1 && diff.inSeconds < 60){
      return diff.inSeconds.toString() + " seconds ago";
    }else if(diff.inMinutes >= 1 && diff.inSeconds < 60){
      return diff.inMinutes.toString() + " minutes ago";
    }else if(diff.inHours >= 1 && diff.inHours < 24){
      return diff.inHours.toString() + " hours ago";
    }else if(diff.inDays >= 1 && diff.inDays < 7){
      if(diff.inDays == 1){
        return diff.inDays.toString() + " day ago";
      }else{
        return diff.inDays.toString() + " days ago";
      }
    }else if(diff.inDays >= 7 && diff.inDays < 30){
      if(diff.inDays >= 7 && diff.inDays < 14){
        return "one week ago";
      } else if(diff.inDays >= 14 && diff.inDays < 21){
        return "two weeks ago";
      }else if(diff.inDays >= 21 && diff.inDays < 30){
        return "three weeks ago";
      }
    }else{
      return "more than a month ago";
    }
  }

}

