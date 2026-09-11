enum AccountabilityIdentificationType {
  expense('Despesa'),
  income('Receita'),
  investment('Investimento');

  final String label;
  const AccountabilityIdentificationType(this.label);
}
