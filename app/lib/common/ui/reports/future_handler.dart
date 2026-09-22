import 'package:flutter/material.dart';

Widget futureHandler(
  Future<dynamic> future,
  Widget Function(dynamic) child, {
  bool hideLoading = false,
}) {
  return Column(
    spacing: 20,
    children: [
      if (!hideLoading) const Text("Carregando..."),
      FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return hideLoading
                ? SizedBox.shrink()
                : SizedBox(
                    height: 50,
                    width: 50,
                    child: const CircularProgressIndicator(),
                  );
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
      ),
    ],
  );
}

class FutureHandler extends StatefulWidget {
  final Future<dynamic> future;
  final Widget Function(dynamic) child;
  final bool hideLoading;

  const FutureHandler({
    super.key,
    required this.future,
    required this.child,
    this.hideLoading = false,
  });

  @override
  State<FutureHandler> createState() => _FutureHandlerState();
}

class _FutureHandlerState extends State<FutureHandler> {
  bool loaded = false;
  late Future<dynamic> _future;

  bool get hide => widget.hideLoading || loaded;

  @override
  void initState() {
    super.initState();
    _future = initLoader();
  }

  Future<dynamic> initLoader() async {
    setState(() => loaded = true);
    return await widget.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return hide
              ? SizedBox.shrink()
              : Column(
                  spacing: 20,
                  children: [
                    const Text("Carregando..."),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: const CircularProgressIndicator(),
                    ),
                  ],
                );
        }

        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Text("Nenhum item encontrado");
        }

        return widget.child(snapshot.data!);
      },
    );
  }
}
