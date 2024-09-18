import 'package:biluca_financas/common/datetime_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("deve retornar o mesmo mês se o parâmetro for zero", () {
    var now = DateTime.now();

    expect(now.subtractMonth(0), now);
  });

  
  test("deve retornar o mês anterior", () {
    var date = DateTime(2024, 9, 1);

    expect(date.subtractMonth(1).day, 1);
    expect(date.subtractMonth(1).month, 8);
    expect(date.subtractMonth(1).year, date.year);
  });

    test("deve retornar ao mês e ano anteriores", () {
    var date = DateTime(2024, 2, 1);

    var result = date.subtractMonth(2);
    expect(result.day, 1);
    expect(result.month, 12);
    expect(result.year, 2023);
  });
}