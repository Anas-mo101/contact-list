import 'dart:convert';
import 'package:flutter/material.dart';

class ContactList extends StatefulWidget {
  const ContactList({ Key? key }) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(title: const Text("Contact List"),),
      body: Center(
        child: FutureBuilder(builder: (context, snapshot){
          var showData = json.decode(snapshot.data.toString());
          return ListView.builder(
            itemCount: showData.length,
            itemBuilder: (BuildContext context, int index){
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
            
          );
        },future: DefaultAssetBundle.of(context).loadString("assets/contacts.json"),
        ),
      ),
    );
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
      return diff.inDays.toString() + " days ago";
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

