import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
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
    var date = DateTime(2024, 1, 1);

    var result = date.subtractMonth(2);
    expect(result.day, 1);
    expect(result.month, 11);
    expect(result.year, 2023);
  });

  test("deve avançar para o próximo mês", () {
    var date = DateTime(2024, 9, 1);

    expect(date.addMonth(1).day, 1);
    expect(date.addMonth(1).month, 10);
    expect(date.addMonth(1).year, date.year);
  });

  test("deve avançar para o próximo mês e ano", () {
    var date = DateTime(2024, 12, 1);

    var result = date.addMonth(1);
    expect(result.day, 1);
    expect(result.month, 1);
    expect(result.year, 2025);
  });

  test("deve avançar avançar o total de mês idendependente da quantidade", () {
    var date = DateTime(2024, 12, 1);

    var result = date.addMonth(13);
    expect(result.day, 1);
    expect(result.month, 1);
    expect(result.year, 2026);
  });
}
