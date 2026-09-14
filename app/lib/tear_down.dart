import 'package:biluca_financas/integrations/embedded_server/embedded_predict_server.dart';
import 'package:get_it/get_it.dart';

Future<void> tearDown() async {
  await GetIt.I<EmbeddedPredictServer>().terminate();
}
