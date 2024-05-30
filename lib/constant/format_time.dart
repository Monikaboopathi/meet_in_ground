import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDate(Timestamp timestamp) {
  DateTime messageDate = timestamp.toDate();
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));

  if (messageDate.isAfter(today)) {
    return DateFormat('hh:mm a').format(messageDate);
  } else if (messageDate.isAfter(yesterday)) {
    return 'Yesterday';
  } else {
    return DateFormat('dd MMM yyyy').format(messageDate);
  }
}
