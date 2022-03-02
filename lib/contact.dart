class Contact implements Comparable<Contact> {
  String name;
  String phone;
  String checkin;
  Contact(this.name, this.phone, this.checkin);

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(json['user'] as String, json['phone'] as String,
        json['checkin'] as String);
  }

  Map toJson() => {'user': name, 'phone': phone, 'checkin': checkin};

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
