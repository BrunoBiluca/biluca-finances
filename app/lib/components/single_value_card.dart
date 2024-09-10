import 'package:biluca_financas/common/formatter.dart';
import 'package:biluca_financas/common/math.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ValuesRelation { positive, negative, neutral }

class SingleValueCard extends StatefulWidget {
  final String title;
  final double currentValue;
  final double? lastValue;
  final bool lessIsPositite;
  const SingleValueCard({
    super.key,
    required this.title,
    required this.currentValue,
    this.lastValue,
    this.lessIsPositite = false,
  });

  @override
  State<SingleValueCard> createState() => _SingleValueCardState();
}

class _SingleValueCardState extends State<SingleValueCard> {
  final Color cardBackground = const Color(0xFF14161D);

  final Color cardBorder = const Color(0xFF232428);

  final Color primaryText = const Color(0xFFE8E6E3);

  final double primaryTextSize = 20;

  final Color secondaryText = const Color(0xFF737373);

  final double secondaryTextSize = 14;

  final Color positiveText = const Color(0xFF43C67C);

  final Color positiveBackgroud = const Color(0xFF122622);

  final Color positiveBorder = const Color(0xFF232428);

  final Color negativeText = const Color(0xFFF54149);

  final Color negativeBackgroud = const Color(0xFF24141B);

  final Color negativeBorder = const Color(0xFF232428);

  final Color neutralText = const Color(0xFF988F81);

  final Color neutralBackgroud = const Color(0xFF232428);

  final Color neutralBorder = const Color.fromARGB(255, 72, 74, 82);

  double? relativePercentage;
  ValuesRelation? relativeStatus;

  @override
  void initState() {
    super.initState();
    if (widget.lastValue != null) {
      relativePercentage = Math.relativePercentage(widget.currentValue, widget.lastValue!);
      relativeStatus = relativePercentage == 0
          ? ValuesRelation.neutral
          : !((relativePercentage! > 0) ^ !widget.lessIsPositite)
              ? ValuesRelation.positive
              : ValuesRelation.negative;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: cardBorder, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Formatter.value(widget.currentValue),
                      key: const Key("valor"),
                      style: TextStyle(
                        color: primaryText,
                        fontSize: primaryTextSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    relativeValue()
                  ],
                ),
                Text(
                  widget.title,
                  key: const Key("título"),
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: secondaryTextSize,
                  ),
                ),
              ],
            ),
            SizedBox(width: 30),
            relativeBox()
          ],
        ),
      ),
    );
  }

  Widget relativeBox() {
    if (relativePercentage == null) {
      return Container();
    }

    return relativeStatus! == ValuesRelation.positive
        ? PositiveValuesRelationIndicator(isUp: relativePercentage! > 0)
        : relativeStatus! == ValuesRelation.negative
            ? NegativeValuesRelationIndicator(isUp: relativePercentage! > 0)
            : const NeutralValuesRelationIndicator();
  }

  StatelessWidget relativeValue() {
    if (relativePercentage == null) {
      return Container();
    }

    var textColor = relativeStatus! == ValuesRelation.positive
        ? positiveText
        : relativeStatus! == ValuesRelation.negative
            ? negativeText
            : neutralText;

    return Text(
      Formatter.relation(relativePercentage!),
      key: const Key("relação"),
      style: TextStyle(
        color: textColor,
        fontSize: primaryTextSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

abstract class ValuesRelationIndicator extends StatelessWidget {
  const ValuesRelationIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: borderColor, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Transform.rotate(
          angle: pi / 8,
          child: Icon(
            icon,
            color: txtColor,
          ),
        ),
      ),
    );
  }

  Color get bgColor;
  Color get borderColor;
  Color get txtColor;
  IconData get icon;
}

class PositiveValuesRelationIndicator extends ValuesRelationIndicator {
  final Color positiveText = const Color(0xFF43C67C);
  final Color positiveBackgroud = const Color(0xFF122622);
  final Color positiveBorder = const Color(0xFF232428);

  final bool isUp;
  const PositiveValuesRelationIndicator({super.key, this.isUp = true});

  @override
  Color get bgColor => positiveBackgroud;

  @override
  Color get borderColor => positiveBorder;

  @override
  IconData get icon => isUp ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down;

  @override
  Color get txtColor => positiveText;
}

class NegativeValuesRelationIndicator extends ValuesRelationIndicator {
  final Color negativeText = const Color(0xFFF54149);
  final Color negativeBackgroud = const Color(0xFF24141B);
  final Color negativeBorder = const Color(0xFF232428);

  final bool isUp;
  const NegativeValuesRelationIndicator({super.key, this.isUp = true});

  @override
  Color get bgColor => negativeBackgroud;

  @override
  Color get borderColor => negativeBorder;

  @override
  IconData get icon => isUp ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down;

  @override
  Color get txtColor => negativeText;
}

class NeutralValuesRelationIndicator extends ValuesRelationIndicator {
  final Color neutralText = const Color(0xFF988F81);
  final Color neutralBackgroud = const Color(0xFF232428);
  final Color neutralBorder = const Color.fromARGB(255, 72, 74, 82);

  const NeutralValuesRelationIndicator({super.key});

  @override
  Color get bgColor => neutralBackgroud;

  @override
  Color get borderColor => neutralBorder;

  @override
  IconData get icon => FontAwesomeIcons.equals;

  @override
  Color get txtColor => neutralText;
}
