import 'package:share_plus/share_plus.dart';
import 'contact.dart';

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

share(Contact con) {
  Share.share(
      'Contact: ${con.name} \n Phone: ${con.phone} \n Added at: ${con.checkin}');
}
