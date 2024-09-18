import 'package:biluca_financas/reports/components/single_value_card/values_relation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("deve retornar uma relação neutra", () {
    var valuesRelation = ValuesRelation(10, 10);

    expect(valuesRelation.percentage, 0);
    expect(valuesRelation.type, ValuesRelationType.neutral);
  });

  test("deve retornar uma relação desconhecida quando o valor relacionado é zero", () {
    var valuesRelation = ValuesRelation(10, 0);

    expect(valuesRelation.type, ValuesRelationType.unknown);
  });


  test("deve retornar uma relação positiva", () {
    var valuesRelation = ValuesRelation(20, 10);

    expect(valuesRelation.percentage, 1);
    expect(valuesRelation.type, ValuesRelationType.positive);
  });

  test("deve retornar uma relação positiva em redução do valor quando marcado como menos é positivo", () {
    var valuesRelation = ValuesRelation(5, 10, lessIsPositite: true);

    expect(valuesRelation.percentage, -.5);
    expect(valuesRelation.type, ValuesRelationType.positive);
  });

  test("deve retornar uma relação negativa", () {
    var valuesRelation = ValuesRelation(5, 10);

    expect(valuesRelation.percentage, -.5);
    expect(valuesRelation.type, ValuesRelationType.negative);
  });

  test("deve retornar uma relação positiva em redução do valor quando marcado como menos é positivo", () {
    var valuesRelation = ValuesRelation(20, 10, lessIsPositite: true);

    expect(valuesRelation.percentage, 1);
    expect(valuesRelation.type, ValuesRelationType.negative);
  });
}
