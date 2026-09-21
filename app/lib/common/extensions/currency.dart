import 'package:intl/intl.dart';

String formatReal(double value) => "R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(value)}";
