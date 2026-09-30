import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String dateTime(DateTime d) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(d);
  static String time(DateTime d) => DateFormat('hh:mm a').format(d);

  static String currency(num amount) =>
      NumberFormat.currency(symbol: 'Rs', decimalDigits: 0).format(amount);

  static String compact(num n) => NumberFormat.compact().format(n);

  static String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}