import 'package:flutter/material.dart';

class FutureHandler<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Reloads only when this value changes; rebuilds for layout changes keep the
  /// data already loaded.
  final Object? dependency;

  const FutureHandler({
    super.key,
    required this.load,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.dependency,
  });

  @override
  State<FutureHandler<T>> createState() => _FutureHandlerState<T>();
}

class _FutureHandlerState<T> extends State<FutureHandler<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  @override
  void didUpdateWidget(covariant FutureHandler<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dependency != widget.dependency) {
      _future = widget.load();
    }
  }

  void _retry() {
    setState(() {
      _future = widget.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loadingBuilder?.call(context) ??
              Column(
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
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              _defaultError(context, snapshot.error!);
        }

        final data = snapshot.data;
        if (data == null) {
          return const Text("Nenhum item encontrado");
        }

        return widget.builder(context, data);
      },
    );
  }

  Widget _defaultError(BuildContext context, Object error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Text('Erro: $error', textAlign: TextAlign.center),
        TextButton.icon(
          key: const Key('future-handler-retry'),
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}
