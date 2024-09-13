double cast(dynamic v) => v is int ? v.toDouble() : v;

extension DoubleExtension on double {
  double subtractP(double percentage) => this - this * percentage;
}
