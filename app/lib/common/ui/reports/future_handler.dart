import 'package:flutter/material.dart';

Widget futureHandler(Future<dynamic> future, Widget Function(dynamic) child) {
  return FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const CircularProgressIndicator();
      }

      if (snapshot.hasError) {
        return Text('Erro: ${snapshot.error}');
      }

      if (!snapshot.hasData) {
        return const Text("Nenhum item encontrado");
      }

      var result = snapshot.data!;
      return child(result);
    },
  );
}
