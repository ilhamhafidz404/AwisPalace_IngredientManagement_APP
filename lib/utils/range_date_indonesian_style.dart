String FormatDateRangeIndonesianStyle(DateTime start, DateTime end) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  return "${start.day} ${months[start.month - 1]} "
      "- ${end.day} ${months[end.month - 1]} ${end.year}";
}
