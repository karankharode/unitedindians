import 'package:date_time_format/date_time_format.dart';

var dateTime = DateTime.now();
var formatteddateTime = dateTime.format('D M j H:m:s P Y');

var months = {
  "Jan": 1,
  "Feb": 2,
  "Mar": 3,
  "Apr": 4,
  "May": 5,
  "Jun": 6,
  "Jul": 7,
  "Aug": 8,
  "Sep": 9,
  "Oct": 10,
  "Nov": 11,
  "Dec": 12,
};

class GMTDateTime {
  String sendingTime() {
    var formatteddateTime = DateTime.now().format('D M j H:i:s P Y');
    List splitTime = formatteddateTime.trim().toString().split(" ");
    String sending =
        "${splitTime[0]} ${splitTime[1]} ${splitTime[2]} ${splitTime[3]} GMT${splitTime[4]} ${splitTime[5]}";
    return sending;
  }

  String formatRecieved(String date_time) {
    List splitTime = date_time.replaceAll("GMT", "").split(" ");
    String gmtRemoved =
        "${splitTime[5]}-${months[splitTime[1].toString()]}-${splitTime[2]} ${splitTime[3]}.0";
    // print(DateTime.parse(gmtRemoved));
    String relativeTime =
        DateTimeFormat.relative(DateTime.parse(gmtRemoved), ifNow: "Just Now",appendIfAfter: "ago",abbr: true,);
    
    return relativeTime;
  }
}
