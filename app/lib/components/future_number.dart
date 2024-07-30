import 'package:biluca_financas/common/formatter.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          return textShimmer();
        }

        if (formatter != null) {
          return Text(formatter!(s.data! as double));
        }

        return Text(Formatter.number(s.data! as double));
      },
    );
  }

  SizedBox textShimmer() {
    return SizedBox(
      width: 200.0,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: Colors.red,
        highlightColor: Colors.yellow,
        child: const Text(
          'Shimmer',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
