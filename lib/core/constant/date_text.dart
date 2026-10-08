const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

String dateText(DateTime d) =>
    '${_months[d.month - 1].substring(0, 3)} ${d.day} ${d.year}';

String monthText(DateTime d) => '${_months[d.month - 1]} ${d.year}';


String monthShort(DateTime d) => _months[d.month - 1].substring(0, 3);