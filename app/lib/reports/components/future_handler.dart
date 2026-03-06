import 'package:flutter/material.dart';

Widget futureHandler(Future<dynamic> future, Widget Function(dynamic) child) {
  return FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const CircularProgressIndicator();
      }

      if (snapshot.data == null) {
        return const Text("Nenhum item encontrado");
      }

      var result = snapshot.data!;
      return child(result);
    },
  );
}
