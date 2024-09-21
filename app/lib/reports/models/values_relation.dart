import 'package:biluca_financas/common/math.dart';
import 'package:biluca_financas/common/switch_adv.dart';

enum ValuesRelationType { positive, negative, neutral, unknown }

class ValuesRelation {
  final double current;
  final double related;

  final bool lessIsPositite;
  late double percentage;
  late ValuesRelationType type;

  ValuesRelation(this.current, this.related, {this.lessIsPositite = false}) {
    if (current == 0) {
      percentage = -1;
      type = ValuesRelationType.unknown;
      return;
    }

    percentage = Math.relativePercentage(current, related);

    type = SwitchAdv(percentage)
        .mapIf((v) => v == 0, ValuesRelationType.neutral)
        .mapIf((v) => !percentage.isFinite, ValuesRelationType.unknown)
        .mapIf((v) => !((v > 0) ^ !lessIsPositite), ValuesRelationType.positive)
        .resolve(unresolve: ValuesRelationType.negative);
  }
}
