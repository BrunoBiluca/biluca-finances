extension DatetimeExtensions on DateTime {
  DateTime subtractMonth(int amount) {
    if (amount == 0) {
      return this;
    }

    int newMonth = month - amount;
    int newYear = year + (newMonth ~/ 12);

    if (newMonth <= 0) {
      newMonth += 12;
      newYear--;
    }

    int lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    return DateTime(
      newYear,
      newMonth,
      day > lastDayOfNewMonth ? lastDayOfNewMonth : day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}
