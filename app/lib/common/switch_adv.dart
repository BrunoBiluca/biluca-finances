class SwitchAdv<T, K> {
  final T v;
  final List<(bool Function(T), K)> expressions = [];
  SwitchAdv(this.v);

  SwitchAdv<T, K> mapIf(bool Function(T) condition, K resolve) {
    expressions.add((condition, resolve));
    return this;
  }

  K? resolve({K? unresolve}) {
    for (var e in expressions) {
      if (e.$1(v)) return e.$2;
    }
    return unresolve;
  }
}
