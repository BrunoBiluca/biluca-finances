import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/components/text_shimmer.dart';
import 'package:flutter/material.dart';

class FutureNumber extends StatelessWidget {
  final Function source;
  final String Function(double n)? formatter;
  const FutureNumber({super.key, required this.source, this.formatter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: source(),
      builder: (c, s) {
        if (s.connectionState != ConnectionState.done) {
          return const TextShimmer();
        }

        if (formatter != null) {
          return Text(formatter!(s.data! as double));
        }

        return Text(Formatter.number(s.data! as double));
      },
    );
  }
}
