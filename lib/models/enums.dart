enum TermStatus {
  available,
  booked,
  cancelled;

  static TermStatus fromInt(int value) => TermStatus.values[value];
  int toInt() => index;
}

enum BookingStatus {
  confirmed,
  cancelledByCustomer,
  cancelledByBusiness,
  completed,
  noShow;

  static BookingStatus fromInt(int value) => BookingStatus.values[value];
  int toInt() => index;
}

enum AppDayOfWeek{
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday;

  static AppDayOfWeek fromInt(int value) => AppDayOfWeek.values[value];
  int toInt() => index;
}