double? safeRatio(num value, num base) {
  if (base == 0) return null;
  return value / base;
}
