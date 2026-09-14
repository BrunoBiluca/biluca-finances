import 'package:biluca_financas/core/accountability/seeds/initialize_identifications.dart';

Future<void> initDatabase() async {
  var seeds = [
    initilizeAccountabilityIdentifications,
  ];

  for (var seed in seeds) {
    await seed();
  }
}
