class GroupedBy<T> {
  final T field;
  final double? total;
  final double? mean;
  GroupedBy(this.field, {this.total, this.mean});
}
