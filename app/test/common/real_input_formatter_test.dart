import 'package:biluca_financas/common/real_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("deve retornar um valor real formatado", () {
    var f = RealInputFormatter();
    var result = f.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "10.00"));

    expect(result.text, "R\$ 10,00");
  });

  test("deve retornar um valor negativa em reais formatado", () {
    var f = RealInputFormatter();
    var result = f.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "-10.00"));

    expect(result.text, "-R\$ 10,00");
  });

  test("deve retornar um valor negativo zerado quando usuário digita apenas o sinal", (){
    var f = RealInputFormatter();
    var result = f.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "-"));

    expect(result.text, "-R\$ 0,00");

    var result2 = f.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: "-002"));

    expect(result2.text, "-R\$ 0,02");
  });
}
