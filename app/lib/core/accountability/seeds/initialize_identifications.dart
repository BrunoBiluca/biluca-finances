import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<void> initilizeAccountabilityIdentifications() async {
  var repo = GetIt.instance<AccountabilityRepo>();
  var identificationsCount = (await repo.getIdentifications()).length;
  if (identificationsCount > 0) return;

  var startIdentifications = [
    AccountabilityIdentification("Supermercado", Colors.blueAccent),
    AccountabilityIdentification("Apoio causa", Colors.grey),
    AccountabilityIdentification("Lanche", Colors.greenAccent),
    AccountabilityIdentification("Rendimento", Colors.yellowAccent),
    AccountabilityIdentification("Outros", const Color.fromARGB(255, 104, 102, 102)),
    AccountabilityIdentification("Saúde", const Color.fromARGB(255, 15, 105, 179)),
    AccountabilityIdentification("Lazer", Colors.redAccent),
    AccountabilityIdentification("Streaming", const Color.fromARGB(255, 180, 57, 48)),
    AccountabilityIdentification("Compras", Colors.brown),
    AccountabilityIdentification("Games", const Color.fromARGB(255, 131, 58, 31)),
    AccountabilityIdentification("Almoço", const Color.fromARGB(255, 68, 156, 113)),
    AccountabilityIdentification("Contas", Colors.pinkAccent),
    AccountabilityIdentification("Educação", Colors.pink),
    AccountabilityIdentification("Salário", Colors.yellow),
    AccountabilityIdentification("Empréstimo", const Color.fromARGB(255, 17, 168, 168)),
    AccountabilityIdentification("Padaria", const Color.fromARGB(255, 105, 240, 112)),
    AccountabilityIdentification("Transporte", const Color.fromARGB(255, 141, 28, 122)),
    AccountabilityIdentification("Extra salário", const Color.fromARGB(255, 228, 217, 66)),
  ];

  for (var i in startIdentifications) {
    repo.addIdentification(i);
  }
}
