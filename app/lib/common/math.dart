class Math {
  static double relativePercentage(double a, double b) {
    if (a == b) return 0.0;
    return a / b - 1;
  }

  static double relativeMultiplier(double a, double b) {
    if (a == b) return 0.0;
    return a / b;
  }
}
